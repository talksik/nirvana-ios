//
//  ConvoViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import Foundation
import AgoraRtcKit


class ConvoViewModel: NSObject, ObservableObject {
    @Published var inCall = false
    
    let firestoreService = FirestoreService()
    
    var agoraKit: AgoraRtcEngineKit?
    var agoraDelegate: AgoraRtcEngineDelegate?
    
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
    }
    
    /**
     @param: friendId: the second person in the convo...the receiver
     **/
    func startConvo(friendId: String) {
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
    func joinConvo(convoId: String, convoAgoraToken: String) {
        // ensure the convo is active and includes 2 people in it currently...shouldn't be shown if not anyway
        
        // ensure that this user leaves all other channels
        self.leaveConvo()
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convoAgoraToken, channelId: "testChannel", info: nil, uid: 0, joinSuccess: {(channel, uid, elapsed) in
            self.inCall = true
        })
    }
    
    // anyone can leave at any time
    func leaveConvo() {
        agoraKit?.leaveChannel(nil)
        
        // if I am the second person in the room, then end the convo
        
        self.inCall = false
    }
    
    // if you are the second to last person in the convo and you leave, you end the convo
    private func endConvo() {
        self.leaveConvo()
        
        AgoraRtcEngineKit.destroy()
    }
}

extension ConvoViewModel {
    func initializeAgoraEngine() {
        // TODO: put app id in environment variables
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c8dfd65deb5c4741bd564085627139d0", delegate: agoraDelegate)
    }
}

extension ConvoViewModel: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("I did join channel")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("I did leave channel")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        // Only one remote video view is available for this
        // tutorial. Here we check if there exists a surface
        // view tagged as this uid.
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
    }
}
