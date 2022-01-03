//
//  InnerCircleViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import Foundation
import AVFoundation
import AlertToast
import SwiftUI

class InnerCircleViewModel: ObservableObject {
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
                return AlertToast(displayMode: .alert, type: .complete(Color.green), title: "Done", subTitle: "removed friend")
            case .addedFriend:
                return AlertToast(displayMode: .alert, type: .complete(Color.green), title: "Done", subTitle: "added friend")
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
                return AlertToast(displayMode: .hud, type: .systemImage("waveform.circle.fill", Color.orange))
            default:
                return AlertToast(displayMode: .hud, type: .error(Color.orange), title: "Something went wrong ‼️")
            }
        }
    }
    
    
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    @Published var isRecording : Bool = false
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private var audioLocalUrl: URL?
    
    private let cloudStorageService = CloudStorageService()
    private let firestoreService = FirestoreService()
    private let pushNotificationService = PushNotificationService()
    
    
    init() {
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
