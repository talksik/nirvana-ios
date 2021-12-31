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
    private var db = Firestore.firestore()
    var convosListener: ListenerRegistration? = nil
    
    let agoraService = AgoraService()
    var agoraKit: AgoraRtcEngineKit?
    
    private var allConvos: [Convo] = []
    @Published var relevantConvos: [Convo] = []
    private var currConvo: Convo? = nil // local cache for updating
    
    func isInCall() -> Bool {
        return self.selectedConvoId != nil
    }
    
    static var relevancyAcceptance = 0.6
    
    override init() {
        super.init()
        
        // start process of data collection
        let userId = AuthSessionStore.getCurrentUserId()
        if userId == nil {
            print("no authenticated user")
        }
        
        // get all active userfriends
        var scopeUserIds: [String] = []
        scopeUserIds.append(userId!)
        
        db.collection("user_friends").whereField("userId", isEqualTo: userId).whereField("isActive", isEqualTo: true)
            .getDocuments() {[weak self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting user's active friends: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let userFriend:UserFriends? = try? document.data(as: UserFriends.self)
                        
                        if userFriend == nil {
                            continue
                        }
                        
                        scopeUserIds.append(userFriend!.friendId)
                    }
                    
                    
                    //TODO: can only use 10 in array for firestore comparison...enact two listeners if need more than that
                    let splicedArray = Array(scopeUserIds.prefix(10))
                    
                    print("the scope of users to search for convos is \(splicedArray)")
                    
                    // initiate convo listener to get all relevant convos
                    //  any convo that is active
                    //  and any of my active friends or I am in that convo
                    //  if am being "called" catch that and join the convo/channel
                    self?.convosListener = self?.db.collection("convos").whereField("state", isEqualTo: ConvoState.active.rawValue).whereField("users", arrayContainsAny: splicedArray)
                        .addSnapshotListener { querySnapshot, error in
                            print("convos listener")
                            guard let documents = querySnapshot?.documents else {
                                print("Error fetching convos \(error!)")
                                return
                            }
                            
                            self?.allConvos.removeAll()
                            self?.relevantConvos.removeAll()
                            
                            for document in querySnapshot!.documents {
                                let convo:Convo? = try? document.data(as: Convo.self)
                                
                                if convo == nil {
                                    continue
                                }
                                
                                // TODO: if convo receiver is me, then join in
                                if convo!.receiverUserId == userId && !(self?.isInCall())! {
                                    self?.joinConvo(convo: convo!)
                                }
                                
                                self?.allConvos.append(convo!)
                            }
                            
                            // only show convos in which I know a majority of the people inside
                            // use relevancyAcceptance value
                            self?.relevantConvos = (self?.allConvos.filter{convo in
                                var relevancyCount = 0
                                // go through all users in this convo
                                for user in convo.users {
                                    if scopeUserIds.contains(user) {
                                        relevancyCount += 1
                                    }
                                }
                                
                                let relevancyScore = Double(relevancyCount / convo.users.count)
                                print("relevancy score: \(relevancyScore)")
                                
                                if relevancyScore > Self.relevancyAcceptance {
                                    print("this convo counts as relevant!!!")
                                    return true
                                }
                                return false
                            })!
                        }
                }
        }
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
                    return
                }
                
                let _ = [userId] // just one user now, and that's me...but no one has joined yet
                // only considered joined when I have officially joined the agora channel
                
                let convo = Convo(id: channelName, leaderUserId: userId, receiverUserId: friendId, agoraToken: token!, state: .initialized, users: [], startedTimestamp: nil, endedTimestamp: nil)
                
                // create a convo/channel in db to notify the other user with proper attributes
                self?.firestoreService.createConvo(convo: convo) {[weak self] res in
                    switch res {
                    case .success:
                        // join the convo myself
                        self?.joinConvo(convo: convo)
                    case .error(let error):
                        print(error)
                    default:
                        return
                    }
                }
            }
        }
    }
    
    func joinConvo(convo: Convo) {
        // ensure that this user leaves all other channels
        if self.isInCall() {
            self.leaveConvo()
        }
        
        // add this convo for the delegate use
        self.currConvo = convo
        
        // update ui to select this one
        self.selectedConvoId = convo.id
        
        self.initializeAgoraEngine() // give delegate up to date object
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convo.agoraToken, channelId: convo.id!, info: nil, uid: 0, joinSuccess: nil)
    }
    
    
    /**
    Allow user to join an active convo
     */
    func joinConvo() {
        // ensure the convo is active and includes 2 people in it currently...shouldn't be shown if not anyway
        
        // ensure that this user leaves all other channels
        if self.isInCall() {
            print("can't join another call, already in one")
            return
        }
        
        let convo = self.relevantConvos.first {convo in
            convo.id == self.selectedConvoId
        }
        
        if convo == nil {
            // handles the offchance that the convo was deactivated or was mistakenly seen by this user
            print("convo not available")
            return
        }
        
        self.currConvo = convo
        
        // TODO: if the convo has more than 10 people, stop user from joining...that's too expensive...
        
        let convoAgoraToken:String = convo!.agoraToken
        let channelName:String = convo!.id!
        
        self.initializeAgoraEngine()
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convoAgoraToken, channelId: channelName, info: nil, uid: 0, joinSuccess: nil)
    }
    
    // anyone can leave at any time
    func leaveConvo() {
        agoraKit?.leaveChannel(nil)
        
        // if I am the second person in the room, then end the convo
        
        self.selectedConvoId = nil
        self.currConvo = nil
        
        AgoraRtcEngineKit.destroy()
    }
}

extension ConvoViewModel {
    func initializeAgoraEngine() {
        // TODO: put app id in environment variables
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c8dfd65deb5c4741bd564085627139d0", delegate: self)
    }
    
    func playJoinAudioEffect(engine: AgoraRtcEngineKit) {
        print("playing JOINED audio sound")
        
        // Sets the audio effect ID.
        let EFFECT_ID:Int32 = 1
        // Sets the path of the audio effect file.
        let filePath = Bundle.main.path(forResource: "joinSound", ofType: "mp3")
        // Sets the number of times the audio effect loops. -1 represents an infinite loop.
        let loopCount = 1
        // Sets the pitch of the audio effect. The value range is 0.5 to 2.0, where 1.0 is the original pitch.
        let pitch: Double = 1.0
        // Sets the spatial position of the audio effect. The value range is -1.0 to 1.0.
        // -1.0 represents the audio effect occurs on the left; 0 represents the audio effect occurs in the front; 1.0 represents the audio effect occurs on the right.
        let pan: Double = 1.0
        // Sets the volume of the audio effect. The value range is 0 to 100. 100 represents the original volume.
        let gain = 100.0
        // Sets whether to publish the audio effect to the remote users. true represents that both the local user and remote users can hear the audio effect; false represents that only the local user can hear the audio effect.
        let publish = false
        // Sets the playback position (ms) of the audio effect file. 500 represents that the playback starts at the 500 ms mark of the audio effect file.
        let startPos: Int32 = 500;
        // Plays the specified audio effect file.
        engine.playEffect(EFFECT_ID, filePath: filePath, loopCount: Int32(loopCount), pitch: pitch, pan: pan, gain: gain, publish: publish, startPos: startPos)
    }
    
    func playLeaveAudioEffect(engine: AgoraRtcEngineKit) {
        print("playing LEFT audio sound")
        
        // Sets the audio effect ID.
        let EFFECT_ID:Int32 = 2
        // Sets the path of the audio effect file.
        let filePath = Bundle.main.path(forResource: "leaveSound", ofType: "mp3")
        // Sets the number of times the audio effect loops. -1 represents an infinite loop.
        let loopCount = 1
        // Sets the pitch of the audio effect. The value range is 0.5 to 2.0, where 1.0 is the original pitch.
        let pitch: Double = 1.0
        // Sets the spatial position of the audio effect. The value range is -1.0 to 1.0.
        // -1.0 represents the audio effect occurs on the left; 0 represents the audio effect occurs in the front; 1.0 represents the audio effect occurs on the right.
        let pan: Double = 1.0
        // Sets the volume of the audio effect. The value range is 0 to 100. 100 represents the original volume.
        let gain = 100.0
        // Sets whether to publish the audio effect to the remote users. true represents that both the local user and remote users can hear the audio effect; false represents that only the local user can hear the audio effect.
        let publish = false
        // Sets the playback position (ms) of the audio effect file. 500 represents that the playback starts at the 500 ms mark of the audio effect file.
        let startPos: Int32 = 500;
        // Plays the specified audio effect file.
        engine.playEffect(EFFECT_ID, filePath: filePath, loopCount: Int32(loopCount), pitch: pitch, pan: pan, gain: gain, publish: publish, startPos: startPos)
    }
}

extension ConvoViewModel: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionStateType, reason: AgoraConnectionChangedReason) {
        self.connectionState = state
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("I did join channel")
        
        self.playJoinAudioEffect(engine: engine)
        
        // TODO: leave channel if it's just me
        
        if let userId = AuthSessionStore.getCurrentUserId() {
            if self.currConvo == nil {
                print("no such convo found")
                return
            }
            
            // set my user status to in convo
            self.firestoreService.updateUserStatus(userId: userId, userStatus: .inConvo) {[weak self] res in
                print(res)
                
                switch res {
                case .success:
                    // update convo in database users array to let them know I am in now
                   
                    self?.currConvo!.users.append(userId)
                    self?.currConvo!.state = .active
                    
                    self?.firestoreService.updateConvo(convo: (self?.currConvo)!) {[weak self] res in
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
        
        // sound effect upon leaving
        self.playLeaveAudioEffect(engine: engine)
        
        if self.currConvo == nil {
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
                    
                    let updatedUsers: [String] = (self?.currConvo!.users.filter{ arrUserId in
                        return arrUserId != userId
                    })!
                    
                    self?.currConvo!.users = updatedUsers
                    
                    // if I am the last one in the convo, then end the convo
                    if self?.currConvo!.users.count == 1 && self?.currConvo!.users[0] == userId {
                        self?.currConvo!.state = .complete
                        self?.currConvo!.endedTimestamp = Date()
                    }
                    
                    self?.firestoreService.updateConvo(convo: (self?.currConvo)!) {[weak self] res in
                        self?.selectedConvoId = nil
                        self?.currConvo = nil
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
        
        self.playJoinAudioEffect(engine: engine)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("a user left")
        
        self.playLeaveAudioEffect(engine: engine)
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
