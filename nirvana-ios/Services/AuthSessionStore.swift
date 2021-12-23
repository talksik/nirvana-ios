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
    @Published var friendsArr: [User] = []
    var messagesArr: [Message] = []
    
    // transformed data for the views
    @Published var friendMessagesDict: [String: [Message]] = [:]
    
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
         let firebaseAuth = Auth.auth()
        
         do {
           try firebaseAuth.signOut()
         } catch let signOutError as NSError {
           print("Error signing out: %@", signOutError)
         }
    }
    
    func unbind () {
        if let handle = self.handler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func setupAuthListen() {
        // monitor authentication changes using firebase
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] res, authUser in
            print("auth listener activated")
            
            guard let self = self else { return }
         
            self.sessionState = authUser == nil ? SessionState.isLoggedOut : SessionState.isAuthenticated
            
            // get the user from the auth table in firebase auth
            if let uid = authUser?.uid {
                // if we have a user, create a new user model
                print("auth listener: Got user: \(uid)")
                print("auth listener: phone number: \(authUser?.phoneNumber)")
                
                // MARK: data listeners for entire environment
                self.activateMainDataListeners(userId: uid)
                
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

struct MasterUserFriendsMessagesModel {
    
}


extension AuthSessionStore {
    
    
    // get all my friends
    // traverse all my friends, and put them into the friendsDict
    
    // get all messages where I am the receiver or sender in the past 5 days let's say
    //          this way, we won't have enormous lists
    // traverse all messages and put them in the friendMessagesDict
    //      [sarth: [arjun's message, sarth's message, arjun's message...], liam: [liam's message, liam's message]]
    // note: that list of messages should be sorted
    
    // can easily now traverse friends and find any messages to do with them
    
    // example:
    // I send a new message to sarth -> goes to messages database -> notification to sarth
    // sarth's data looks like this: [arjun: [...arjun's message, sarth's reply...]]
    
    
    
    private func activateMainDataListeners(userId: String) {
        // MARK: keeping the @Published user object updated
        // TODO: THIS WON"T UPDATE VIEW since user is a reference type...can manually publish...research and learn more
        self.firestoreService.getUserRealtime(userId: userId) {[weak self] realtimeUpdatedUser in
            if realtimeUpdatedUser != nil {
                print("up to date user: \(realtimeUpdatedUser)")
                self?.user = realtimeUpdatedUser
                self?.objectWillChange.send()
            }
        }
        
        // MARK: keeping the friends list updated
        // TODO: break into firestoreService metadata of each change...later tho since this listener will barely get changes
            // different actions on additions, modifications, and removals
            
            // parse through the new result set
            // if already exists in dict, then make sure not to delete the associated list
            
        // order: when the relationship was created...also easy for user
        // limit: for my protection of db costs lol
        // TODO: use the indexes I created
        db.collection("user_friends").whereField("userId", isEqualTo: userId).limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching user's friends: \(error!)")
                    return
                }
                
                // resetting array to reset friends
                self.friendsArr = []
                
                for document in querySnapshot!.documents {
                    let userFriend:UserFriends? = try? document.data(as: UserFriends.self)
                    
                    // get user and initialize this user in dict
                    self.db.collection("users").document(userFriend!.friendId).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let returnedUser = try? document.data(as: User.self)
                            DispatchQueue.main.async {
                                if returnedUser != nil {
                                    self.friendsArr.append(returnedUser!)
                                    
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
                
                
                // TODO: optimize later with the conditionals
//                guard let snapshot = querySnapshot else {
//                    print("Error fetching user's friends: \(error!)")
//                    return
//                }
//                snapshot.documentChanges.forEach { diff in
//
//                    if (diff.type == .added) {
//                        print("New friend in circle: \(diff.document.data())")
//                    }
//                    if (diff.type == .modified) {
//                        // maybe it was deactivated or activated
//                        print("Modified relationship: \(diff.document.data())")
//                    }
//                    if (diff.type == .removed) {
//                        print("Removed city: \(diff.document.data())")
//                    }
//                }
            }
        
        
        // MARK: listener for messages
        
        // TODO: don't know if we need a listener for sent messages as we can alter our model from local and add to the dictionary
        // senderIdReceiverIdComposite: composite array of strings which contains the senderId and receiverId as elements
        // order: sent time should make it easy to add to dict
        // limit: because each user should have most 12 friends and so would at most need 24 messages to show turns and all that...save myself from hackers here...unless a user gets 100 messages from someone, and that too at least they will be ordered
        
        // SOLUTION: composite with array
        db.collection("messages").whereField("senderIdReceiverIdComposite", arrayContains: userId).order(by: "sentTimestamp", descending: true).limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                    guard let documents = querySnapshot?.documents else {
                        print("error in fetching messages: \(error!)")
                        return
                    }
                    print("going through all messages now that the query found changes")
                
                    // clearing dict to allow clean list of messages to be put forth
                    //optimize this? but also saving on memory and same db reads
                    self.friendMessagesDict.removeAll()
                
                    self.messagesArr = documents.compactMap { (queryDocumentSnapshot) -> Message? in
                        do {
                            let currMessage = try queryDocumentSnapshot.data(as: Message.self)
                            print("new message received! \(currMessage!.sentTimestamp)")
                            
                            DispatchQueue.main.async {
                                if currMessage != nil { // not really possible but just check
                                    // if the user doesn't exist for the dictionary, then add it
                                    // this means it's most likely someone new (never had user_friend relationship before) messaging for the user's inbox
                                    // TODO: prolly want to make a call to get this sender user details for the inbox, but they should either be in the friendsArr or their are not a friend so won't be there
                                    // also add in any messages where I am the sender
                                    if currMessage!.senderId == userId { // if I am the sender
                                        if self.friendMessagesDict[currMessage!.receiverId] == nil {
                                            self.friendMessagesDict[currMessage!.receiverId] = [currMessage!]
                                        } else {
                                            self.friendMessagesDict[currMessage!.receiverId]?.append(currMessage!)
                                        }
                                    }
                                    else  { // if I am receiving
                                        if self.friendMessagesDict[currMessage!.senderId] == nil {
                                            self.friendMessagesDict[currMessage!.senderId] = [currMessage!]
                                        } else {
                                            self.friendMessagesDict[currMessage!.senderId]?.append(currMessage!)
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
    }
    
    private func deinitDataListeners() {
        
    }
}
