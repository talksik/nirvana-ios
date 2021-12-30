//
//  ConvoViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import Foundation
import AgoraRtcKit

class ConvoViewModel: NSObject, ObservableObject {
    private var testingUIMode = true
    
    @Published var selectedConvoId:String? = nil
    @Published var connectionState: AgoraConnectionStateType? = nil
    
    let firestoreService = FirestoreService()
    
    let testConvos: [Convo] = [
        Convo(id: "testChannel", leaderUserId: "VWVPKCrNmMeZlkEeZxuJ0Wsgq0C3", receiverUserId: "zd6PpD3TmnQUDoy6noS9aZpuPWr1", agoraToken: "006c8dfd65deb5c4741bd564085627139d0IAAqbHMFow9oQ8BN0WCkFrkGBTqFTjlbr6tJmFH5judwbnZXrgMAAAAAEADQ943gC8nOYQEAAQALyc5h", state: .connected)
    ]
    
    var agoraKit: AgoraRtcEngineKit?
    
    func isInCall() -> Bool {
        return self.selectedConvoId != nil
    }
    
    override init() {
        super.init()
        
        // initiate convo listener to get all relevant convos
        //  any convo that is active
        //  and any of my active friends are in that convo
        //  if am being "called" catch that and join the convo/channel
        
        // only show convos in which I know a majority of the people inside
        
        // initiate agora engine
        self.initializeAgoraEngine()
    }
    
    deinit {
        // deinit the firestore listener
        // deinit the agora engine
        print("deiniting and cleaning up convo view model/agora services")
        
        AgoraRtcEngineKit.destroy()
        
        self.leaveConvo()
    }
    
    /**
     @param: friendId: the second person in the convo...the receiver
     **/
    func startConvo(friendId: String) {
        if testingUIMode {
            print("testing mode...not doing anything")
            return
        }

        
        if let userId = AuthSessionStore.getCurrentUserId() {
            
        }
        
        // need to make sure the other user is online
        
        // get a new agora token from cloud function
        
        // create a convo/channel in db to notify the other user with proper attributes
        
        // join the convo myself
    }
    
    /**
    Allow user to join an active convo
     */
    func joinConvo() {
        if testingUIMode {
            print("testing mode...not doing anything")
            
            return
        }
        
        // ensure the convo is active and includes 2 people in it currently...shouldn't be shown if not anyway
        
        // ensure that this user leaves all other channels
        if self.isInCall() {
            self.leaveConvo()
        }
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        
        let convo = self.testConvos.first {convo in
            convo.id == self.selectedConvoId
        }
        
        if convo == nil {
            // handles the offchance that the convo was deactivated or was mistakenly seen by this user
            print("convo not available")
            return
        }
        
        
        // TODO: if the convo has more than 10 people, stop user from joining...that's too expensive...
        
        
        let convoAgoraToken:String = convo!.agoraToken
        let channelName:String = convo!.id!
        
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convoAgoraToken, channelId: channelName, info: nil, uid: 0, joinSuccess: nil)
    }
    
    // anyone can leave at any time
    func leaveConvo() {
        if testingUIMode {
            print("testing mode...not doing anything")
            
            return
        }
        
        agoraKit?.leaveChannel(nil)
        
        // if I am the second person in the room, then end the convo
        
        self.selectedConvoId = nil
    }
}

extension ConvoViewModel {
    func initializeAgoraEngine() {
        // TODO: put app id in environment variables
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c8dfd65deb5c4741bd564085627139d0", delegate: self)
    }
}

extension ConvoViewModel: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        self.connectionState = state
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("I did join channel")
                
        // set my user status to in convo
        
        // leave channel if it's just me
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        // leave channel if I am the only one in it
        
        print("I did leave channel")
        
        
        self.selectedConvoId = nil
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("new user joined \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("user joined left")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("did occur warning: \(warningCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("did occur error: \(errorCode.rawValue)")
        
        // publish an error in view...toast or something
        
        self.selectedConvoId = nil
    }
}
