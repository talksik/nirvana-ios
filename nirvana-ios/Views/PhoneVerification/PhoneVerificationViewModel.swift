//
//  PhoneVerificationViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/17/21.
//

import Foundation
import FirebaseAuth

final class PhoneVerificationViewModel : ObservableObject  {
    private var firestoreService = FirestoreService()
    
    // TODO: add alert message handler here that publishes changes to ui based on business logic errors
    
    public func verifyPhoneAndSendSMS(phoneNumber: String) {
        // TODO: do some string validation here
        // do auth stuff from firebase
        
        
    }
    
    public func createOrUpdateUser(userId: String, phoneNumber: String, completion: @escaping((_ res: ServiceState?) -> ())) {
        // TODO: set all in a transaction or batch write
        
        // get user - 1 result set cost
        self.firestoreService.getUser(userId: userId) {[weak self] resultingUser in
            print("user that was received from get: \(resultingUser?.id)")
                        
            if resultingUser == nil {// if empty, create user
                let newUser = User(id: userId, phoneNumber: phoneNumber)
                
                print("creating new user with this object: \(newUser)")
                
                self?.firestoreService.createUser(user: newUser) { res in
                    print(res)
                    completion(res)
                }
            } else { // if not, change last logged in value
                var user = resultingUser
                
                // assign to nil so that server can fill it in
                user!.lastLoggedInTimestamp = nil
                
                self?.firestoreService.updateUser(user: user!) {res in
                    completion(res)
                }
            }
        }
    }
}
