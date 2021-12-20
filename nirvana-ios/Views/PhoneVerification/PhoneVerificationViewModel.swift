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
    
    public func createOrUpdateUser(userId: String, phoneNumber: String) {
        // TODO: set all in a transaction or batch write
        
        // get user - 1 result set cost
        self.firestoreService.getUser(userId: userId) {[weak self] resultingUser in
            print("user that was received from get: \(resultingUser?.id)")
            
            
            if resultingUser == nil {// if empty, create user - 1 result set cost..prolly higher cost
                print("creating new user with id: \(userId)")
                let newUser = User(id: userId, phoneNumber: phoneNumber)
                print("verify the id stayed the same: \(newUser.id)")
                self?.firestoreService.createUser(user: newUser)
            } else { // if not, change last logged in value
                var user = resultingUser
                
                // assign to nil so that server can fill it in
                user!.lastLoggedInTimestamp = nil
                
                let res = self?.firestoreService.updateUser(user: user!)
                print(res)
            }
        }
    }
}
