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
    
    private var GIDconfig:GIDConfiguration
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        // create google sign in configuration object
        let clientID = FirebaseApp.app()?.options.clientID
        self.GIDconfig = GIDConfiguration(clientID: clientID!)
        
        print(clientID)
        
        self.setupAuthListen()
    }
    
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
        self.handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("auth listener activated")
            
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user.displayName!)")
                self.user = User(
                    _uid: user.uid, _email: user.email, _displayName: user.displayName, _profilePic: user.photoURL, _phoneNumber: user.phoneNumber)
                
                self.sessionState = .isAuthenticated
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
