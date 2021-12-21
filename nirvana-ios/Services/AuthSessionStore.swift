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
    @Published var sessionState: SessionState = SessionState.isLoggedOut
    
    // TODO: figure out which ones to publish
    var friendsArr: [User] = []
    var messagesArr: [Message] = []
    
    // transformed data for the views
    var friendMessagesDict: [String: [Message]] = [:]
    
    // TODO: temporary...should not have this here
    private var db = Firestore.firestore()
        
    private var GIDconfig:GIDConfiguration
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    private var firestoreService: FirestoreService = FirestoreService()
    
    init(isPreview: Bool) {
        let fakeUser = User(id: UUID().uuidString, nickname: "arjunya", phoneNumber: "+19302919293")
        self.user = User()
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
        self.firestoreService.getUserRealtime(userId: userId) {[weak self] realtimeUpdatedUser in
            if realtimeUpdatedUser != nil {
                print("up to date user: \(realtimeUpdatedUser)")
                self?.user = realtimeUpdatedUser
            }
        }
        
        // MARK: keeping the friends list updated
        // TODO: break into firestoreService
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
                
                for document in querySnapshot!.documents {
                    let userFriend:UserFriends? = try? document.data(as: UserFriends.self)
                    
                    // get user and initialize this user in dict
                    self.db.collection("users").document(userFriend!.friendId).getDocument { (document, error) in
                        if let document = document, document.exists {
                            let returnedUser = try? document.data(as: User.self)
                            if returnedUser != nil {
                                self.friendsArr.append(returnedUser!)
                                
                                // if this friend do not exist in the dict, add it to show up in my circle
                                if self.friendMessagesDict[returnedUser!.id!] == nil {
                                    self.friendMessagesDict[returnedUser!.id!] = []
                                }
                                
                                print("added this user to the array of users for user's circle")
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
        
        
        // MARK: keeping the list of messages updated
        // one listener for received messages
        
        // don't know if we need a listener for sent messages as we can alter our model from local and add to the dictionary
        
        // order: sent time should make it easy to add to dict
        // limit: because each user should have most 12 friends and so would at most need 24 messages to show turns and all that...save myself from hackers here
        // TODO: use the indexes I created
        db.collection("messages").whereField("receiverId", isEqualTo: userId).limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching messages: \(error!)")
                    return
                }
                for document in querySnapshot!.documents {
                    // decode and add to arr and dic
                    let currMessage:Message? = try? document.data(as: Message.self)
                    
                    if currMessage != nil { // not really possible but just check
                        // if the user doesn't exist for the dictionary, then add it
                        // this means it's most likely someone new (never had user_friend relationship before) messaging for the user's inbox
                        // TODO: prolly want to make a call to get this sender user details for the inbox
                        if self.friendMessagesDict[currMessage!.senderId] == nil {
                            self.friendMessagesDict[currMessage!.senderId] = [currMessage!]
                        } else {
                            self.friendMessagesDict[currMessage!.senderId]?.append(currMessage!)
                        }
                    }
                }
                
                // TODO: optimize later
//                guard let snapshot = querySnapshot else {
//                    print("Error fetching messages: \(error!)")
//                    return
//                }
//                snapshot.documentChanges.forEach { diff in
//                    if (diff.type == .added) {
//                        print("New message: \(diff.document.data())")
//
//                        // keep array of messages sorted, but this should automatically be sorted?
//                    }
//                    if (diff.type == .modified) {
//                        // nothing to really do here
//                        print("Modified message: \(diff.document.data())")
//                    }
//                    if (diff.type == .removed) {
//                        print("Removed message: \(diff.document.data())")
//                    }
//                }
            }
        
    }
    
    private func deinitDataListeners() {
        
    }
}
