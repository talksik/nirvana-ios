//
//  AuthSessionStore.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/13/21.
//

import Foundation
import Firebase
import Combine

class AuthSessionStore : ObservableObject {
    @Published public var firebaseUser : User?
    private var handle: AuthStateDidChangeListenerHandle?
    
    func listen() {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.firebaseUser = User(
                    _uid: user.uid, _email: user.email, _displayName: user.displayName, _profilePic: user.photoURL, _phoneNumber: user.phoneNumber)
            } else {
                // if we don't have a user, set our session to nil
                self.firebaseUser = nil
            }
        }
    }
}
