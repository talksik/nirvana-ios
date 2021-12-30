//
//  ConvoViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import Foundation
import AgoraRtcKit


class ConvoViewModel: ObservableObject {
    let firestoreService = FirestoreService()
    
    var agoraKit: AgoraRtcEngineKit?
    var agoraDelegate: AgoraRtcEngineDelegate?
    
    init() {
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
        
        // finally join channel
        agoraKit?.joinChannel(byToken: convoAgoraToken, channelId: "testChannel", info: nil, uid: 0, joinSuccess: {(channel, uid, elapsed) in
            
        })
    }
    
    // anyone can leave at any time
    private func leaveConvo() {
        agoraKit?.leaveChannel(nil)
    }
    
    // if you are the second to last person in the convo and you leave, you end the convo
    private func endConvo() {
        AgoraRtcEngineKit.destroy()
    }
}

extension ConvoViewModel {
    func initializeAgoraEngine() {
        // TODO: put app id in environment variables
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c8dfd65deb5c4741bd564085627139d0", delegate: agoraDelegate)
    }
}
