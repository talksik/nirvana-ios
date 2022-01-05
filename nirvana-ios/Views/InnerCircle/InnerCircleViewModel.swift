//
//  InnerCircleViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import Foundation
import AVFoundation
import AVKit
import AlertToast
import SwiftUI


class InnerCircleViewModel: NSObject, ObservableObject {
    @Published var toast: Toast? {
        didSet {
            self.showToast = true
        }
    }
    @Published var showToast: Bool = false
    
    enum Toast: Identifiable {
        var id: Self { self }
        
        case startedClip
        case problemSendingClip
        case nothingRecorded
        case clipSent
        
        case maxFriendsInCircle
        case cannotFriendYourself
        case addedFriend
        case removedFriend
        
        case circlesPreview
        case remoteWorkPreview
        case moreSpacesPreview
        case shareAddyPreview
        
        case generalError
        
        
        var view: AlertToast {
            switch self {
            case .shareAddyPreview:
                return AlertToast(displayMode: .hud, type: .systemImage("house.circle", NirvanaColor.dimTeal), title: "coming soon", subTitle: "share an addy for 24 hours")
            case .moreSpacesPreview:
                return AlertToast(displayMode: .hud, type: .systemImage("command.circle", NirvanaColor.dimTeal), title: "coming soon", subTitle: "more spaces")
            case .remoteWorkPreview:
                return AlertToast(displayMode: .hud, type: .systemImage("suitcase.fill", NirvanaColor.dimTeal), title: "coming soon", subTitle: "remote work productivity at it's best")
            case .circlesPreview:
                return AlertToast(displayMode: .hud, type: .systemImage("snowflake", NirvanaColor.dimTeal), title: "coming soon", subTitle: "group convos reinvented")
            case .removedFriend:
                return AlertToast(displayMode: .alert, type: .complete(Color.green), title: "removed friend", subTitle: "...tap to dismiss")
            case .addedFriend:
                return AlertToast(displayMode: .alert, type: .complete(Color.green), title: "added friend", subTitle: "...tap to dismiss")
            case .cannotFriendYourself:
                return AlertToast(displayMode: .hud, type: .error(Color.orange), title: "silly! 🙉", subTitle: "you cannot friend yourself")
            case .maxFriendsInCircle:
                return AlertToast(displayMode: .hud, type: .systemImage("person.crop.circle.badge.exclamationmark.fill", Color.orange), title: "circle full!", subTitle: "tap on an existing friend and hold down on their icon in the bottom left to remove them to make space")
            case .nothingRecorded:
                return AlertToast(displayMode: .hud, type: .systemImage("exclamationmark.triangle.fill", NirvanaColor.teal), title: "nothing recorded", subTitle: "please try again")
            case .clipSent:
                return AlertToast(displayMode: .hud, type: .systemImage("paperplane.circle.fill", NirvanaColor.teal))
            case .problemSendingClip:
                return AlertToast(displayMode: .hud, type: .error(Color.orange), title: "problem sending clip", subTitle: "please try again")
            case .startedClip:
                return AlertToast(displayMode: .hud, type: .systemImage("waveform.and.mic", Color.orange))
            default:
                return AlertToast(displayMode: .hud, type: .error(Color.orange), title: "Something went wrong ‼️")
            }
        }
    }
        
    var audioRecorder : AVAudioRecorder!
    
    var queuePlayer = AVQueuePlayer()
    var avplayer: AVPlayer?
    
    private var cachedPlayerItemsDict: [String: URL] = [:] // firebase audio url to local url
    
    @Published var isRecording : Bool = false
    
    @Published var messagesListeningProgress: Float = 1.0
    static let multiplier: Float64 = 0.01
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private var audioLocalUrl: URL?
    
    private let cloudStorageService = CloudStorageService()
    private let firestoreService = FirestoreService()
    private let pushNotificationService = PushNotificationService()
    
    
    override init() {
        super.init()
        
        self.setupMessagingAudioSession()
    }
}

// audio stuff
extension InnerCircleViewModel {
    func setupMessagingAudioSession() {
        // separate set up for listening vs recording
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.duckOthers, .allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            try audioSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker) // allow playing in silent mode
            
        } catch {
            print("Can not setup the Recording")
        }
    }
    
    func startRecording() {
        let filePath = getTemporaryDirectory().appendingPathComponent("\(UUID().uuidString).m4a")
        
        print("file name of recording will be : \(filePath)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            isRecording = true
            
            self.toast = .startedClip
            
            self.audioLocalUrl = filePath // setting this for later use when recording is stopped
            
        } catch {
            print("Failed to Setup the Recording")
        }
    }
    
    // sender should be current user
    // receiver is the person we are sending to
    func stopRecording(sender:User, receiver: User) {
        if isRecording == false || audioRecorder == nil {
            print("was not recording")
            // no need for toast because user knows he wasn't trying to record
            return
        }
        
        audioRecorder.stop()
        isRecording = false
        
        if self.audioLocalUrl != nil {
            // upload to the cloud storage
            DispatchQueue.global(qos: .background).async {
                self.cloudStorageService.uploadLocalUrl(localFileUrl: self.audioLocalUrl!) {[weak self] audioDataUrl in
                    if audioDataUrl == nil {
                        print("there was an error in uploading file")
                        DispatchQueue.main.async {
                            self?.toast = .problemSendingClip
                        }
                        return
                    }
                    
                    let newMessage = Message(sendId: sender.id!, receivId: receiver.id!, audioDUrl: audioDataUrl!.absoluteString)
                    
                    // create a new message in firestore with the url for receiving user to automatically get notified
                    self?.firestoreService.createMessage(message: newMessage) {[weak self] res in
                        print(res)
                        
                        DispatchQueue.main.async {
                            switch res {
                            case .success:
                                // play woosh
                                self?.playWoosh()
                                
                                self?.toast = .clipSent
                                
                                // sending push notification if there was a device token for this friend
                                if receiver.deviceToken != nil && receiver.nickname != nil {
                                    self?.pushNotificationService.sendPushNotification(to: receiver.deviceToken!, title: "🌱Nirvana", body: "continue your conversation with \(sender.nickname ?? "your friend")")
                                }
                                
                                // delete local audio file from user's phone so that it doesn't take crazy space
                                print("stopped recording: file about to get deleted from \(self?.getTemporaryDirectory()) with filename: \(self?.audioLocalUrl)")
                                
                                try? FileManager.default.removeItem(at: (self?.audioLocalUrl)!)
                            case .error(let err):
                                print(err)
                                self?.toast = .problemSendingClip
                            default:
                                self?.toast = .problemSendingClip
                            }
                        }
                    }
                }
            }
            
        }
        else {
            print("nothing recorded, can't send")
            self.toast = .problemSendingClip
        }
    }
    
    func getTemporaryDirectory() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    
}

// handling saving device token for notifications
extension InnerCircleViewModel {
    func setUpPushNotifications() {
        self.pushNotificationService.registerForPushNotifications()
        
        self.pushNotificationService.updateFirestorePushTokenIfNeeded()
    }
}

// handle activating or deactivating friends
extension InnerCircleViewModel {
    func activateOrDeactiveInboxUser(activate: Bool, userId: String, friendId: String)  {
        // validation
        // make sure userId is not the same as friendId...don't want people friending themselves
        if userId == friendId {
            print("you cannot friend yourself")
            self.toast = .cannotFriendYourself
            return
        }
        
        // setting timestamps to nil to make sure that new server timestamp is set
        var userFriend = UserFriends(userId: userId, friendId: friendId, isActive: activate, lastUpdatedTimestamp: nil)
        
        self.firestoreService.createOrUpdateUserFriends(userFriend: userFriend, activateOrDeactivate: activate) {[weak self] res in
            switch res {
            case .success:
                if activate {
                    self?.toast = .addedFriend
                }
                else {
                    self?.toast = .removedFriend
                }
            case .error(let err):
                print(err)
                self?.toast = .generalError
            default:
                self?.toast = .generalError
            }
        }
    }
}

extension InnerCircleViewModel {
    // update listen count to update ui to remove orange telling them that they listened to it already
    func updateMessageListenCount() {
        
    }
}

// everything to do with listening to messages
extension InnerCircleViewModel {
    func playWoosh() {
        if let wooshFilePath = Bundle.main.url(forResource: "woosh", withExtension: "mp3") {
            self.avplayer = AVPlayer(url: wooshFilePath)
            avplayer?.play()
        }
        else {
            print("didn't get the woosh sound")
        }
    }
    
    func playPop() {
        if let popFilePath = Bundle.main.url(forResource: "pop", withExtension: "mp3") {
            self.avplayer = AVPlayer(url: popFilePath)
            avplayer?.play()
        }
        else {
            print("didn't get the pop sound")
        }
    }
    
    func stopPlayingAnyAudio() {
        self.queuePlayer.removeAllItems()
    }
    
    func playAssets(audioUrls: [URL]) {
        // clearing the player to make room for this friend's convo or to deselect this user
        self.stopPlayingAnyAudio()
        
        // reset progress
        self.messagesListeningProgress = Float(0)
        
        var AVPlayerItems: [AVPlayerItem] = []
        for url in audioUrls {
            // if we have a player in the cache, then play it from there
            if self.cachedPlayerItemsDict.keys.contains(url.absoluteString), let localUrl = self.cachedPlayerItemsDict[url.absoluteString] {
                // keep the cachedplayer item in tact as the player messes with those items
                let asset = AVAsset(url: localUrl)
                let playerItem = AVPlayerItem(asset: asset)
                AVPlayerItems.append(playerItem)
                print("playing a message from cache")
            } else {
                let asset = AVAsset(url: url)
                let playerItem = AVPlayerItem(asset: asset)
                AVPlayerItems.append(playerItem)
            }
        }
        
        if AVPlayerItems.count <= 0 {
            print("no messages to play...send a message to user")
            return
        }
        
        self.playPop()
        
        // start playing if there are messages to listen to
        print("have \(AVPlayerItems.count) messages to play")
        
        // reverse the items because we want to listen to the most recent messages in order
        AVPlayerItems = AVPlayerItems.reversed()
        
        // TODO: make sure these options are viable for different scenarios
        self.queuePlayer = AVQueuePlayer(items: AVPlayerItems)
        self.queuePlayer.automaticallyWaitsToMinimizeStalling = false
        self.queuePlayer.play()
        
        print("player queued up items!!!")
        
        DispatchQueue.global(qos: .background).async {
            self.addBoundaryTimeObserver(playerItems: AVPlayerItems)
        }
    }
    
    func addBoundaryTimeObserver(playerItems: [AVPlayerItem]) {
        var totalDuration = CMTime.zero
        for item in playerItems {
            totalDuration = CMTimeAdd(totalDuration, item.asset.duration)
        }
        
        // TODO: not hitting the last one/100%
        // it either plays on time or there is a little lag on multiple items...
        // offset this by adding 1 when it reaches the totalDuration as it's longer
        totalDuration = CMTimeSubtract(totalDuration, CMTimeMakeWithSeconds(1, preferredTimescale: 1))
        
        var times = [NSValue]()
        // Set initial time to zero
        var currentTime = CMTime.zero
        // Divide the asset's duration into quarters.
        let interval = CMTimeMultiplyByFloat64(totalDuration, multiplier: Self.multiplier)
        
        // Build boundary times based on multiplier
        while currentTime <= totalDuration {
            currentTime = currentTime + interval
            times.append(NSValue(time: currentTime))
        }
        
        
        if times.count > 0 {
            // Add time observer. Observe boundary time changes on the main queue.
            self.queuePlayer.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
                // Update UI
                self?.messagesListeningProgress += Float(Self.multiplier)
            }
        }
    }
    
//    func periodTimeObserver() {
    
    // notify every half second
//    let timeScale = CMTimeScale(NSEC_PER_SEC)
//    let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
    
    
    // have the total duration, let's say 100
    
    // want to keep adding to our backend: seconds listened so far
    
    // devide by the total duration seconds to get the progress
    
//        var totalListened: Double = 0.0
//        var lastValue: Double = 0.0
//        queuePlayer.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] TOTime in
//            // reset counter once we get to subsequent playeritems
//            if TOTime.seconds < lastValue {
//                totalListened += (TOTime.seconds - 0)
//            } else {
//                totalListened += (TOTime.seconds - lastValue)
//            }
//            print("\(TOTime.seconds)")
//            print("total seconds listened so far \(totalListened)")
//
//            self?.messagesListeningProgress = Float(totalListened / totalMessagesDurationSeconds)
//
//            lastValue = TOTime.seconds
//        }
//    }
    
//    func removeBoundaryTimeObserver() {
//        if let timeObserverToken = timeObserverToken {
//            self.queuePlayer.removeTimeObserver(timeObserverToken)
//            self.timeObserverToken = nil
//        }
//    }
    
    func cacheIncomingMessages(friendMessagesDict: [String: [Message]]) {
        // TODO: not firing for some reason onreceive of new data or not including new data
        guard let userId = AuthSessionStore.getCurrentUserId() else {return}
        
        DispatchQueue.global(qos: .background).async {
            // get all relevant messages that the user may listen to
            // don't want to cache all messages
            for friendId in friendMessagesDict.keys {
                let messagesRelatedToFriend = friendMessagesDict[friendId] ?? []
                
                if messagesRelatedToFriend.count == 0 {
                    return
                }
                
                for message in messagesRelatedToFriend {
                    // if it's starting to get to my messages then don't play
                    if message.senderId == userId {
                        break
                    }
                    
                    // only add to queue if we can convert the database url to a valid url here
                    if let audioUrl = URL(string: message.audioDataUrl) { // check if it's a valid url
                        if !self.cachedPlayerItemsDict.keys.contains(message.audioDataUrl) {
                            // save to play from mem later
                            
                            let task = URLSession.shared.dataTask(with: audioUrl) {[weak self] (data, response, error) in
                                guard let data = data else { return }
                                print(data)
                                
                                if let cacheFilePath = self?.getTemporaryDirectory().appendingPathComponent("\(UUID().uuidString).m4a") {
                                    try? data.write(to: cacheFilePath)
                                    
                                    // save in local cache
                                    self?.cachedPlayerItemsDict[audioUrl.absoluteString] = cacheFilePath
                                }
                            }

                            task.resume()
                        }
                    }
                }
            }
        }
        
        // TODO: need way of deleting cache when we close app or something...can rile up the cost
    }
}


