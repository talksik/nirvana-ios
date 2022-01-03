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
        
        case generalError
        
        
        var view: AlertToast {
            switch self {
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
                return AlertToast(displayMode: .hud, type: .systemImage("waveform.and.mic", Color.orange), subTitle: "you're on")
            default:
                return AlertToast(displayMode: .hud, type: .error(Color.orange), title: "Something went wrong ‼️")
            }
        }
    }
        
    var audioRecorder : AVAudioRecorder!
    var queuePlayer = AVQueuePlayer()
    
    @Published var isRecording : Bool = false
    
    @Published var messagesListeningProgress: Float = 0.0
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private var audioLocalUrl: URL?
    
    private let cloudStorageService = CloudStorageService()
    private let firestoreService = FirestoreService()
    private let pushNotificationService = PushNotificationService()
    
    
    override init() {
        super.init()
        
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
}

// audio stuff
extension InnerCircleViewModel {
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
            self.cloudStorageService.uploadLocalUrl(localFileUrl: self.audioLocalUrl!) {[weak self] audioDataUrl in
                if audioDataUrl == nil {
                    print("there was an error in uploading file")
                    self?.toast = .problemSendingClip
                    return
                }
                
                let newMessage = Message(sendId: sender.id!, receivId: receiver.id!, audioDUrl: audioDataUrl!.absoluteString)
                
                // create a new message in firestore with the url for receiving user to automatically get notified
                self?.firestoreService.createMessage(message: newMessage) {[weak self] res in
                    print(res)
                    
                    switch res {
                    case .success:
                        
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
    func stopPlayingAnyAudio() {
        self.queuePlayer.removeAllItems()
    }
    
    // TODO: print statements slowing it down?
    func playAssets(audioUrls: [URL]) {
        // clearing the player to make room for this friend's convo or to deselect this user
        self.stopPlayingAnyAudio()
        
        var totalMessagesDurationSeconds = CMTime.zero
        var AVPlayerItems: [AVPlayerItem] = []
        for url in audioUrls {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            
            totalMessagesDurationSeconds = CMTimeAdd(totalMessagesDurationSeconds, asset.duration)

            // notification for when each playeritem is done playing
//            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

            
            AVPlayerItems.append(playerItem)
        }
        
        if AVPlayerItems.count <= 0 {
            print("no messages to play...send a message to user")
            return
        }
        
        // start playing if there are messages to listen to
        print("have \(AVPlayerItems.count) messages and \(totalMessagesDurationSeconds) seconds to play")
        
        // reverse the items because we want to listen to the most recent messages in order
        AVPlayerItems = AVPlayerItems.reversed()
        
        // TODO: make sure these options are viable for different scenarios
        self.queuePlayer = AVQueuePlayer(items: AVPlayerItems)
        self.queuePlayer.automaticallyWaitsToMinimizeStalling = false
        self.queuePlayer.playImmediately(atRate: 1)
//                                queuePlayer.play()
        
        print("player queued up items!!!")
        
        self.addBoundaryTimeObserver(totalDuration: totalMessagesDurationSeconds)
        
        // TODO: right now not updating all of that
        // update the listencount and firstlistentimestamp of those messages in firestore
        // this should update ui to show that there is no message to show
        
    }
    
    func addBoundaryTimeObserver(totalDuration: CMTime) {
        var multiplier: Float64 = 0.05
        
        // reset progress
        self.messagesListeningProgress = Float(multiplier * 2)
        
        var times = [NSValue]()
        // Set initial time to zero
        var currentTime = CMTime.zero
        // Divide the asset's duration into quarters.
        let interval = CMTimeMultiplyByFloat64(totalDuration, multiplier: multiplier)
        
        // Build boundary times based on multiplier
        while currentTime <= totalDuration {
            currentTime = currentTime + interval
            times.append(NSValue(time: currentTime))
        }
        // this last one to make sure we get a full loop
        times.append(NSValue(time: totalDuration))
        
        // Add time observer. Observe boundary time changes on the main queue.
        // TODO: not hitting the last one/100%
        self.queuePlayer.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            // Update UI
            self?.messagesListeningProgress += Float(multiplier)
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
        
}

extension InnerCircleViewModel {
//    @objc func playerDidFinishPlaying(sender: Notification) {
//        // Your code here
//        print("finished playing an item")
//
//        self.numberofMessagesToPlay -= 1
//    }
}
