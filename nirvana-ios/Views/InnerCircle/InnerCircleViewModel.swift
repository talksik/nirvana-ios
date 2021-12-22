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
    
    private var audioLocalUrl: URL?
    
    let cloudStorageService = CloudStorageService()
    let firestoreService = FirestoreService()
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Can not setup the Recording")
        }
        
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
    func stopRecording(senderId:String, receiverId:String) {
        audioRecorder.stop()
        isRecording = false
        
        if self.audioLocalUrl != nil {
            // upload to the cloud storage
            self.cloudStorageService.uploadLocalUrl(localFileUrl: self.audioLocalUrl!) {[weak self] audioDataUrl in
                if audioDataUrl == nil {
                    print("there was an error in uploading file")
                    return
                }
                
                let newMessage = Message(receiverId: receiverId, senderId: senderId, listenCount: 0, audioDataUrl: audioDataUrl!.absoluteString)
                
                // create a new message in firestore with the url for receiving user to automatically get notified
                self?.firestoreService.createMessage(message: newMessage) {[weak self] res in
                    print(res)
                    
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

