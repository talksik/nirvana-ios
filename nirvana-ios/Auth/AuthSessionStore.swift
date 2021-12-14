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
}

final class AuthSessionStore: ObservableObject, SessionStore {
    @Published var user : User?
    @Published var sessionState: SessionState = SessionState.isLoggedOut
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        self.setupAuthListen()
    }
    
    func signInOrCreateUser() {
        
    }
    
    func logOut() {
        try? Auth.auth().signOut()
    }
    
    func unbind () {
        if let handle = self.handler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

private extension AuthSessionStore {
    func setupAuthListen() {
        // monitor authentication changes using firebase
        self.handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.user = User(
                    _uid: user.uid, _email: user.email, _displayName: user.displayName, _profilePic: user.photoURL, _phoneNumber: user.phoneNumber)
            } else {
                // if we don't have a user, set our session to nil
                self.user = nil
            }
        }
    }
}
