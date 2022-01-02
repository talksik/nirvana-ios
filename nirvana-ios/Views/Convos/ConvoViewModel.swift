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
    @Published var connectionState: AgoraConnectionStateType?
    
    let firestoreService = FirestoreService()
    private var db = Firestore.firestore()
    var convosListener: ListenerRegistration? = nil
    
    let agoraService = AgoraService()
    // TODO: put the value in environment variables
    var agoraKit: AgoraRtcEngineKit?
    
    private var allConvos: [Convo] = []
    @Published var relevantConvos: [Convo] = []
    
    func isInCall() -> Bool {
        return self.selectedConvoId != nil
    }
    
    static var relevancyAcceptance = 0.6
    
    func initializeAgoraEngine() {
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: "c8dfd65deb5c4741bd564085627139d0", delegate: self)
    }
    
    override init() {
        super.init()
        
        initializeAgoraEngine()
        
        // start process of data collection
        let userId = AuthSessionStore.getCurrentUserId()
        if userId == nil {
            print("no authenticated user")
            return
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
                                
                                // if convo receiver is me and I'm not in a call or this call already, then join in
                                if convo!.receiverUserId == userId && !(self?.isInCall())!
                                    && convo!.receiverEndedTimestamp == nil {
                                    print("I am the direct receiver...joining convo")
                                    self?.joinConvo(convo: convo!)
                                }
                                // if I am in a convo in which the last/loner has left, I need to leave the convo
                                else if convo!.receiverEndedTimestamp != nil && (self?.isInCall())! && convo!.users.contains(userId!) {
                                    print("I am the last one now... ending the convo")
                                    self?.leaveConvo()
                                } //also if I am added after a receiver was added and I am not already in a convo, then join the call
                                else if convo!.users.contains(userId!) && !(self?.isInCall())! {
                                    // should be free or online and not in another call unless it's a race condition
                                    print("I was added onto the call because I was free...joining automatically")
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
        // TODO: make sure that this gets fired if someone closes the app
        
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
        
        // update ui to select this one
        self.selectedConvoId = convo.id
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convo.agoraToken, channelId: convo.id!, info: nil, uid: 0, joinSuccess: nil)
    }
    
    
    /**
    Allow user to join an active convo
     */
    func joinConvo(convoId: String) {
        // ensure the convo is active and includes 2 people in it currently...shouldn't be shown if not anyway
        
        // ensure that this user leaves all other channels        
        
        let convo = self.relevantConvos.first {convo in
            convo.id == convoId
        }
        
        if convo == nil {
            // handles the offchance that the convo was deactivated or was mistakenly seen by this user
            print("convo not available")
            return
        }
        
        // TODO: if the convo has more than 10 people, stop user from joining...that's too expensive...
        
        self.selectedConvoId = convoId
        let convoAgoraToken:String = convo!.agoraToken
        let channelName:String = convo!.id!
        
        print("joining convo: \(channelName)")
        
        self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
        // finally join channel
        self.agoraKit?.joinChannel(byToken: convoAgoraToken, channelId: channelName, info: nil, uid: 0, joinSuccess: nil)
    }
    
    func addThirdPartyToConvo(friendId: String) {
        // recheck if this other friend that I am adding is online/free
        
        if !self.isInCall() {
            print("not in a call, can't invite/force someone else...must have a selected convo")
            return
        }
        
        // get the currconvo details
        var convo = self.relevantConvos.first {convo in
            convo.id == self.selectedConvoId
        }
        if convo == nil {
            print("convo not available")
            return
        }
        
        // update convo users array with this other friend
        convo!.users.append(friendId)
        
        self.firestoreService.updateConvo(convo: convo!) {[weak self] res in
            print("updated with new friend added in the convo")
        }
    }
    
    // anyone can leave at any time
    func leaveConvo() {
        agoraKit?.leaveChannel(nil)
        
        let userId = AuthSessionStore.getCurrentUserId()
        
        if userId == nil {
            print("not authenticated...can't join channel")
            return
        }
        
        if self.selectedConvoId == nil {
            print("not in a convo currently!")
            return
        }
        
        self.firestoreService.updateUserStatus(userId: userId!, userStatus: .online) {[weak self] res in
            print(res)
            
            switch res {
            case .success:
                print("updated user status")
            case .error(let error):
                print(error)
            default:
                return
            }
        }
        
        self.firestoreService.getConvo(channelName: self.selectedConvoId!) {[weak self] convo in
            if convo == nil {
                print("no such convo found")
                return
            }
            
            var updatedConvo = convo
            //update convo in database to show that I left...if I am the last person, also close out the channel
            
            // if I am the last one in the convo, then end the convo in the db
            if updatedConvo!.users.count == 1 && updatedConvo!.users[0] == userId {
                updatedConvo!.state = .complete
                updatedConvo!.endedTimestamp = Date()
            } // if I am second to last, the last guy is a loner
            else if updatedConvo!.users.count == 2 && updatedConvo!.users.contains(userId!) {
                updatedConvo!.receiverEndedTimestamp = Date()
            }
            
            let updatedUsers: [String] = updatedConvo!.users.filter{ arrUserId in
                return arrUserId != userId
            }
            
            updatedConvo!.users = updatedUsers
            
            self?.firestoreService.updateConvo(convo: updatedConvo!) {[weak self] res in
                self?.selectedConvoId = nil
                
                print("left convo officially in our db as well")
            }
        }
    }
    
    func destroyInstance() {
        AgoraRtcEngineKit.destroy()
    }
    
    func joinedConvoCallback() {
        
    }
}

extension ConvoViewModel {
    
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
        
        let userId = AuthSessionStore.getCurrentUserId()
        
        if userId == nil {
            print("not authenticated...can't join channel")
            return
        }
        
        self.firestoreService.getConvo(channelName: channel) {convo in
            if convo == nil {
                print("no such convo found")
                return
            }
            
            var updatedConvo = convo
            
            // set my user status to inConvo
            self.firestoreService.updateUserStatus(userId: userId!, userStatus: .inConvo) {[weak self] res in
                print(res)
                
                switch res {
                case .success:
                    // update convo in database users array to let them know I am in now
                   
                    updatedConvo!.users.append(userId!)
                    updatedConvo!.state = .active
                    
                    self?.firestoreService.updateConvo(convo: updatedConvo!) {[weak self] res in
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
