//
//  ConvoViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import Foundation
import AgoraRtcKit
import Firebase

class ConvoViewModel: NSObject, ObservableObject {
    @Published var selectedConvoId:String? = nil
    @Published var connectionState: AgoraConnectionStateType? = nil
    
    let firestoreService = FirestoreService()
    let agoraService = AgoraService()
    
    @Published var relevantConvos: [Convo] = []
    
    var agoraKit: AgoraRtcEngineKit?
    
    func isInCall() -> Bool {
        return self.selectedConvoId != nil
    }
    
    var convosListener: ListenerRegistration? = nil
    
    private var db = Firestore.firestore()
    
    private var allConvos: [Convo] = []
    
    private var relevancyAcceptance = 0.6
    
    func activateDataListener(activeFriendsIds: [String]) {
        // initiate convo listener to get all relevant convos
        //  any convo that is active
        //  and any of my active friends or I am in that convo
        //  if am being "called" catch that and join the convo/channel
        var scopeUserIds: [String] = []
        scopeUserIds += activeFriendsIds
        
        // I want to get back convos that involve me
        if let userId = AuthSessionStore.getCurrentUserId() {
            scopeUserIds.append(userId)
        }
        
        print("the scope of users to search for convos is \(scopeUserIds)")
        
        self.convosListener = db.collection("convos").whereField("state", isEqualTo: ConvoState.active.rawValue).whereField("users", arrayContainsAny: scopeUserIds)
            .addSnapshotListener { querySnapshot, error in
                print("convos listener")
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching convos \(error!)")
                    return
                }
                
                self.allConvos.removeAll()
                self.relevantConvos.removeAll()
                
                for document in querySnapshot!.documents {
                    let convo:Convo? = try? document.data(as: Convo.self)
                    
                    if convo == nil {
                        continue
                    }
                    
                    self.allConvos.append(convo!)
                }
                
                // only show convos in which I know a majority of the people inside
                // use relevancyAcceptance value
                self.relevantConvos = self.allConvos.filter{convo in
                    var relevancyCount = 0
                    // go through all users in this convo
                    for user in convo.users {
                        if scopeUserIds.contains(user) {
                            relevancyCount += 1
                        }
                    }
                    
                    if Double(relevancyCount / convo.users.count) > self.relevancyAcceptance {
                        print("this convo counts as relevant!!!")
                        return true
                    }
                    return false
                }
            }
        
        // initiate agora engine
        self.initializeAgoraEngine()
    }
    
    deinit {
        // deinit the firestore listener
        self.convosListener?.remove()
        
        // deinit the agora engine
        print("deiniting and cleaning up convo view model/agora services")
        
        AgoraRtcEngineKit.destroy()
        
        self.leaveConvo()
    }
    
    /**
     @param: friendId: the second person in the convo...the receiver
     **/
    func startConvo(friendId: String) {
        // TODO: need to make sure the other user is online or already did in view
        
        // making sure this user is authenticated
        if let userId = AuthSessionStore.getCurrentUserId() {
            let channelName = UUID().uuidString
            
            // get a new agora token from cloud function
            self.agoraService.getAgoraTokenCF(channelName: channelName) {[weak self] token in
                if token == nil {
                    print("error in getting token")
                }
                
                let users = [userId] // just one user now, and that's me...but no one has joined yet
                // only considered joined when I have officially joined the agora channel
                
                var convo = Convo(id: channelName, leaderUserId: userId, receiverUserId: friendId, agoraToken: token!, state: .initialized, users: [], startedTimestamp: nil, endedTimestamp: nil)
                
                // create a convo/channel in db to notify the other user with proper attributes
                self?.firestoreService.createConvo(convo: convo) {[weak self] res in
                    switch res {
                    case .success:
                        // join the convo myself
                        self?.joinConvo(channelName: channelName, agoraToken: token!)
                    case .error(let error):
                        print(error)
                    default:
                        return
                    }
                }
            }
        }
    }
    
    func joinConvo(channelName: String, agoraToken: String) {
        // ensure that this user leaves all other channels
        if self.isInCall() {
            self.leaveConvo()
        }
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        // finally join channel
        self.agoraKit?.joinChannel(byToken: agoraToken, channelId: channelName, info: nil, uid: 0, joinSuccess: nil)
    }
    
    
    /**
    Allow user to join an active convo
     */
    func joinConvo() {
        // ensure the convo is active and includes 2 people in it currently...shouldn't be shown if not anyway
        
        // ensure that this user leaves all other channels
        if self.isInCall() {
            self.leaveConvo()
        }
        
        let convo = self.relevantConvos.first {convo in
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
        
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convoAgoraToken, channelId: channelName, info: nil, uid: 0, joinSuccess: nil)
    }
    
    // anyone can leave at any time
    func leaveConvo() {
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
        
        // TODO: play a sound when I join the channel
            
        // TODO: leave channel if it's just me
        
        
        var convo = self.relevantConvos.first {convo in
            convo.id == self.selectedConvoId
        }
        if convo == nil {
            print("no such convo found")
            return
        }
        
        if let userId = AuthSessionStore.getCurrentUserId() {
            // set my user status to in convo/red
            self.firestoreService.updateUserStatus(userId: userId, userStatus: .inConvo) {[weak self] res in
                print(res)
                
                switch res {
                case .success:
                    // update convo in database users array to let them know I am there
                   
                    convo?.users.append(userId)
                    convo?.state = .active
                    
                    self?.firestoreService.updateConvo(convo: convo!) {[weak self] res in
                        print(res)
                    }
                case .error(let error):
                    print(error)
                default:
                    return
                }
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("I did leave channel")
        
        var convo = self.relevantConvos.first {convo in
            convo.id == self.selectedConvoId
        }
        if convo == nil {
            print("no such convo found")
            return
        }
        
        if let userId = AuthSessionStore.getCurrentUserId() {
            // set my user status to online
            self.firestoreService.updateUserStatus(userId: userId, userStatus: .online) {[weak self] res in
                print(res)
                
                switch res {
                case .success:
                    //update convo in database to show that I left...if I am the last person, also close out the channel
                    
                    let updatedUsers: [String] = convo!.users.filter{ arrUserId in
                        return arrUserId != userId
                    }
                    
                    convo!.users = updatedUsers
                    
                    // if I am the last one in the convo, then end the convo
                    if convo!.users.count == 1 && convo!.users[0] == userId {
                        convo!.state = .complete
                        convo!.endedTimestamp = Date()
                    }
                    
                    self?.firestoreService.updateConvo(convo: convo!) {[weak self] res in
                        self?.selectedConvoId = nil
                        print("left convo officially in our db as well")
                    }
                case .error(let error):
                    print(error)
                default:
                    return
                }
            }
        }
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
