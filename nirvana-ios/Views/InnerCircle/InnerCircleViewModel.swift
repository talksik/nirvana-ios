//
//  InnerCircleViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/16/21.
//

import Foundation
import AVFoundation

class InnerCircleViewModel: ObservableObject {
    var audioRecorder : AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    
    @Published var isRecording : Bool = false
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private var audioLocalUrl: URL?
    
    private let cloudStorageService = CloudStorageService()
    private let firestoreService = FirestoreService()
    private let pushNotificationService = PushNotificationService()
    private let agoraService = AgoraService()
    
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
                    return
                }
                
                let newMessage = Message(sendId: sender.id!, receivId: receiver.id!, audioDUrl: audioDataUrl!.absoluteString)
                
                // create a new message in firestore with the url for receiving user to automatically get notified
                self?.firestoreService.createMessage(message: newMessage) {[weak self] res in
                    print(res)
                    
                    // sending push notification if there was a device token
                    if receiver.deviceToken != nil && receiver.nickname != nil {
                        self?.pushNotificationService.sendPushNotification(to: receiver.deviceToken!, title: "🌱Nirvana", body: "continue your conversation with \(sender.nickname ?? "your friend")")
                    }
                    
                    // delete local audio file from user's phone so that it doesn't get crazy
                    print("stopped recording: file about to get deleted from \(self?.getTemporaryDirectory()) with filename: \(self?.audioLocalUrl)")
                    
                    try? FileManager.default.removeItem(at: (self?.audioLocalUrl)!)
                }
            }
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
    func activateOrDeactiveInboxUser(activate: Bool, userId: String, friendId: String, completion: @escaping((_ state: ServiceState) -> ()))  {
        // validation
        // make sure userId is not the same as friendId...don't want people friending themselves
        if userId == friendId {
            completion(ServiceState.error(ServiceError(description: "You cannot friend yourself, silly!")))
            return
        }
        
        // setting timestamps to nil to make sure that new server timestamp is set
        var userFriend = UserFriends(userId: userId, friendId: friendId, isActive: activate, lastUpdatedTimestamp: nil)
        
        self.firestoreService.createOrUpdateUserFriends(userFriend: userFriend, activateOrDeactivate: activate) {[weak self] res in
            completion(res)
        }
    }
}

extension InnerCircleViewModel {
    // update listen count to update ui to remove orange telling them that they listened to it already
    func updateMessageListenCount() {
        
    }
}

// everything related to calls and such
extension InnerCircleViewModel {
    func getAgoraToken() {
        if let uid = AuthSessionStore.getCurrentUserId() {
            self.agoraService.getAgoraUserTokenServer(channelName: uid)
        }
        else {
            print("no user authenticated to get an agora token")
        }
    }    
}
