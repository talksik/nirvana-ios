//
//  AuthSessionStore.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import Foundation
import Firebase
import Combine
import FirebaseAuth
import GoogleSignIn
import SwiftUI

enum SessionState {
    case notCheckedYet
    case isAuthenticated
    case isLoggedOut
}

protocol SessionStore {
    var sessionState:SessionState { get }
    var user:User? { get }
    
    func signInOrCreateUser()
    func logOut()
    func unbind()
    func setupAuthListen()
}

final class AuthSessionStore: ObservableObject, SessionStore {
    @Published var user : User?
    @Published var sessionState: SessionState = SessionState.notCheckedYet
    
    // TODO: figure out which ones to publish
    var messagesArr: [Message] = []
    var userFriendsDict: [String: UserFriends] = [:] // all active and inactive relationships
    
    // transformed data for the views
    @Published var friendsArr: [String] = []
    @Published var inboxUsersArr: [String] = []
    @Published var relevantUsersDict: [String: User] = [:] // all cached/snapshotted users from db for app use
    @Published var relevantMessagesByUserDict: [String: [Message]] = [:] // note, this is all messages related to me
    
    private var dataListeners: [ListenerRegistration] = []
    private var listenersActive = false // false on app/processes killed
    
    // TODO: temporary...should not have this here
    private var db = Firestore.firestore()
        
    private var GIDconfig:GIDConfiguration
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    private var firestoreService: FirestoreService = FirestoreService()
    
    init(isPreview: Bool) {
        let fakeUser = User(id: UUID().uuidString, nickname: "arjunya", phoneNumber: "+19302919293")
        self.user = fakeUser
        
        let clientID = FirebaseApp.app()?.options.clientID
        self.GIDconfig = GIDConfiguration(clientID: clientID!)
    }
    
    init() {
        // create google sign in configuration object
        let clientID = FirebaseApp.app()?.options.clientID
        self.GIDconfig = GIDConfiguration(clientID: clientID!)
        
        print("the google client id: prolly shouldn't be printing this: \(clientID)")
        
        self.setupAuthListen()
    }
    
    // MARK: OLD for google sign in with link
    func signInOrCreateUser() {
        if GIDSignIn.sharedInstance.currentUser == nil {
            guard
                let viewController = UIApplication.shared.windows.first!.rootViewController
            else {
                return
            }
            
            GIDSignIn.sharedInstance.signIn(with: self.GIDconfig, presenting: viewController)
                {[self] user, err in
                    
                    if err != nil {
                        print(err!.localizedDescription)
                        return
                    }
                    
                    guard
                      let authentication = user?.authentication,
                      let idToken = authentication.idToken
                    else {
                      return
                    }

                    let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                   accessToken: authentication.accessToken)
                    
                    // sign in with firebase
                    self.firebaseAuth(withCredentials: credential)
                }
        }
    }
    
    // MARK: OLD for google sign in with link
    func firebaseAuth(withCredentials authCred: AuthCredential) {
        Auth.auth().signIn(with: authCred) { result, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let user = result?.user else {
                return
            }
            
            // User is signed in
            print(user.displayName ?? "Success!")
            print(user)
        }
    }
    
    func logOut() {
         do {
           try Auth.auth().signOut()
             
           self.deinitDataListeners()
         } catch let signOutError as NSError {
           print("Error signing out: %@", signOutError)
         }
    }
    
    func unbind () {
        if let handle = self.handler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func getCurrentUserId() -> String?  {
        return Auth.auth().currentUser?.uid
    }
    
    func setupAuthListen() {
        // monitor authentication changes using firebase
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] res, authUser in
            print("auth listener activated")
            
            guard let self = self else { return }
         
            self.sessionState = authUser == nil ? SessionState.isLoggedOut : SessionState.isAuthenticated
            print("set the session state to \(self.sessionState)")
            
            // get the user from the auth table in firebase auth
            if let uid = authUser?.uid {
                // if we have a user, create a new user model
                print("auth listener: Got user: \(uid)")
                print("auth listener: phone number: \(authUser?.phoneNumber)")
                
            } else {
                // if we don't have a user, set our session to nil
                self.user = nil
                self.sessionState = .isLoggedOut
            }
        }
    }
}

extension UIApplication {
  func getRootViewController() -> UIViewController {
      guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
      
      guard let root = screen.windows.first?.rootViewController else {
          return .init()
      }
      
      return root
  }

}


// activate data listeners for the main data throughout the app
extension AuthSessionStore {
    // get all my friends
    // traverse all my friends, and put them into the friendsDict
    
    // get all messages where I am the receiver or sender in the past 5 days let's say
    //          this way, we won't have enormous lists
    // traverse all messages and put them in the relevantMessagesByUserDict
    //      [sarth: [arjun's message, sarth's message, arjun's message...], liam: [liam's message, liam's message]]
    // note: that list of messages should be sorted
    
    // can easily now traverse friends and find any messages to do with them
    
    // example:
    // I send a new message to sarth -> goes to messages database -> notification to sarth
    // sarth's data looks like this: [arjun: [...arjun's message, sarth's reply...]]
    
    func activateMainDataListeners() {
        // do nothing if the snapshots are already alive
        if self.listenersActive {
            print("listeners already alive...no point reinitiating")
            return
        }
        
        // extra validation to make sure that we are authenticated although should be if this is called
        if self.sessionState != SessionState.isAuthenticated {
            print("can't initiate data listeners...user not authenticated")
            return
        }
        
        // can't get proper listeners working if don't have current user's id
        let currUserId = self.getCurrentUserId()
        if currUserId == nil {
            print("no user id available to initiate data listeners")
            return
        }
        
        // MARK: keeping the @Published user object updated
        // TODO: THIS WON'T UPDATE VIEW since user is a reference type...can manually publish...research and learn more
        self.firestoreService.getUserRealtime(userId: currUserId!) {[weak self] realtimeUpdatedUser in
            if realtimeUpdatedUser != nil {
                print("up to date user: \(realtimeUpdatedUser)")
                self?.user = realtimeUpdatedUser
                self?.objectWillChange.send()
            }
        }
        
        // MARK: keeping the friends list updated
        // TODO: break into firestoreService metadata of each change...later tho since this listener will barely get changes
        let friendsListener = db.collection("user_friends").whereField("userId", isEqualTo: currUserId).limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                print("friends listener activated")
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching user's friends: \(error!)")
                    return
                }
                
                // resetting array to reset friends
                self.userFriendsDict.removeAll()
                self.friendsArr.removeAll() // updating to keep the friends in order
                
                for document in querySnapshot!.documents {
                    let userFriend:UserFriends? = try? document.data(as: UserFriends.self)
                    
                    if userFriend == nil {
                        continue
                    }
                    
                    self.userFriendsDict[userFriend!.friendId] = userFriend!
                    
                    // get user and initialize this user in dict
                    self.db.collection("users").document(userFriend!.friendId).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let returnedUser = try? document.data(as: User.self)
                            
                            DispatchQueue.main.async {
                                if returnedUser != nil {
                                    self.relevantUsersDict[userFriend!.friendId] = returnedUser!
                                    
                                    // making sure that I clear the inbox if this user came from the inbox...regardless of
                                    // whether I accepted or rejected them
                                    if self.inboxUsersArr.contains(userFriend!.friendId) {
                                        self.inboxUsersArr = self.inboxUsersArr.filter {inboxUserId in
                                            return inboxUserId != userFriend!.friendId
                                        }
                                    }
                                    
                                    if userFriend!.isActive {
                                        self.friendsArr.append(userFriend!.friendId)
                                    }
                                    
                                    self.objectWillChange.send()
                                    
                                    print("added this user to the array of users for user's circle\(returnedUser?.nickname)")
                                }
                            }
                        } else {
                            print("user doesn't exist from user friend relationship")
                            // should not happen
                        }
                    }
                }
            }
        
        // listener for people who have me as an active friend might make inbox easier
        // where friendId = me, isActive = true...this way it's a published property that can update the ui
        // as inbox users is only being called on load
        
        let inboxUsersListener = db.collection("user_friends").whereField("friendId", isEqualTo: currUserId).whereField("isActive", isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                print("inbox users listener")
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching friends who have me as a friend: \(error!)")
                    return
                }
                
                self.inboxUsersArr.removeAll()
                
                for document in querySnapshot!.documents {
                    let userFriend:UserFriends? = try? document.data(as: UserFriends.self)
                    
                    if userFriend == nil {
                        continue
                    }
                                        
                    // if this user is not already a friend, active or inactive/rejected, then get their user data and add to inbox
                    if self.userFriendsDict.keys.contains(userFriend!.userId) {
                        print("already have this user in my circle or I rejected them \(userFriend?.userId)")
                        continue
                    }
                    else {
                        self.firestoreService.getUser(userId: userFriend!.userId) {[weak self] returnedUser in
                            if returnedUser == nil {
                                print("couldn't get new user info")
                                return
                            }
                            print("new user for inbox fetched \(returnedUser!.nickname)")
                            
                            DispatchQueue.main.async {
                                // add data to our app cache of users for their info down the road
                                self?.relevantUsersDict[userFriend!.userId] = returnedUser!
                                self?.inboxUsersArr.append(userFriend!.userId)
                            }
                        }
                    }
                }
            }
        
        // MARK: listener for messages
        
        // TODO: don't know if we need a listener for sent messages as we can alter our model from local and add to the dictionary
        // senderIdReceiverIdComposite: composite array of strings which contains the senderId and receiverId as elements
        // order: sent time should make it easy to add to dict
        // limit: because each user should have most 12 friends and so would at most need 24 messages to show turns and all that...save myself from hackers here...unless a user gets 100 messages from someone, and that too at least they will be ordered
        
        // SOLUTION: composite with array
        let messagesListener = db.collection("messages").whereField("senderIdReceiverIdComposite", arrayContains: currUserId).order(by: "sentTimestamp", descending: true).limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                    print("messages listener activated")
                
                    guard let documents = querySnapshot?.documents else {
                        print("error in fetching messages: \(error!)")
                        return
                    }
                    print("going through all messages now that the query found changes")
                
                    // clearing dict to allow clean list of messages to be put forth
                    //optimize this? but also saving on memory and same db reads
                    self.relevantMessagesByUserDict.removeAll()
                
                    self.messagesArr = documents.compactMap { (queryDocumentSnapshot) -> Message? in
                        do {
                            let currMessage = try queryDocumentSnapshot.data(as: Message.self)
                            print("new message received! \(currMessage!.sentTimestamp)")
                            
                            DispatchQueue.main.async {
                                if currMessage != nil { // not really possible but just check
                                    // if the user doesn't exist for the dictionary, then add it
                                    // this means it's most likely someone new (never had user_friend relationship before) messaging for the user's inbox
                                    // TODO: prolly want to make a call to get this sender user details for the inbox, but they should either be in the friendsDict or their are not a friend so won't be there
                                    // also add in any messages where I am the sender
                                    if currMessage!.senderId == currUserId { // if I am the sender
                                        if self.relevantMessagesByUserDict[currMessage!.receiverId] == nil {
                                            self.relevantMessagesByUserDict[currMessage!.receiverId] = [currMessage!]
                                        } else {
                                            self.relevantMessagesByUserDict[currMessage!.receiverId]?.append(currMessage!)
                                        }
                                    }
                                    else  { // if I am receiving
                                        if self.relevantMessagesByUserDict[currMessage!.senderId] == nil {
                                            self.relevantMessagesByUserDict[currMessage!.senderId] = [currMessage!]
                                        } else {
                                            self.relevantMessagesByUserDict[currMessage!.senderId]?.append(currMessage!)
                                        }
                                    }
                                }
                                
                                self.objectWillChange.send()
                            }
                            
                            return currMessage
                        } catch {
                            print(error)
                        }
                        return nil
                    }                
                }
        
        self.listenersActive = true
        
        // adding listeners to be able to deinit later
        // TODO: make sure to have this listener avaible available to deinit as well
        // self.dataListeners.append(currUserListener)
        self.dataListeners.append(messagesListener)
        self.dataListeners.append(friendsListener)
        self.dataListeners.append(inboxUsersListener)
        
    }
    
    func deinitDataListeners() {
        for listener in self.dataListeners {
            listener.remove()
        }
        
        print("deactivated listeners!")
        
        self.listenersActive = false
    }
}


// manage whether user is online or not
extension AuthSessionStore {
    func updateUserStatus(userStatus: UserStatus) {
        // if user is authenticated
        if self.sessionState == .isAuthenticated {
            // if user already has the status that we want to update to, no need to update
            // remember that the user is updated realtime so we have the newest user data
            if self.user?.userStatus == userStatus {
                // do nothing...already have this status
                print("user already has status: \(userStatus)")
            }
            else {
                if let uid = self.getCurrentUserId() {
                    self.firestoreService.updateUserStatus(userId: uid, userStatus: userStatus) {res in
                       print(res)
                    }
                }
            }
        }
        
        print("not authenticated can't change user status")
    }
}
