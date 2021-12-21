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
    var friends: [User] = []
    var messages: [Messages] = []
    
    // transformed data for the views
    var friendsDict: [String:User] = [:]
    var friendMessagesDict: [String: [Messages]] = [:]
    
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
            
        db.collection("userFriends").whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching user's friends: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New friend in circle: \(diff.document.data())")
                        
                        // re-sort my circle alphabetically or by some other means
                        // need to keep it looking the same everytime
                    }
                    if (diff.type == .modified) {
                        // maybe it was deactivated or activated
                        print("Modified relationship: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
                        print("Removed city: \(diff.document.data())")
                    }
                }
            }
        
        
        // MARK: keeping the list of messages updated
        
    }
    
    private func deinitDataListeners() {
        
    }
}
