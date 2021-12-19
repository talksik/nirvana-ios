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
    // TODO: add alert message handler here that publishes changes
    
    public func verifyPhoneAndSendSMS(phoneNumber: String) {
        // TODO: do some string validation here
        // do auth stuff from firebase
        
        
    }
    
    public func createOrUpdateUser(userId: String, phoneNumber: String) {
        // TODO: set all in a transaction or batch write
        
        // get user - 1 result set cost
        var user = firestoreService.getUser(userId: userId)
        print("user that was received from get: \(user?.id)")
        
        if user == nil {// if empty, create user - 1 result set cost..prolly higher cost
            let newOrExistingUser = User(id: userId, phoneNumber: phoneNumber)
            firestoreService.createUser(user: newOrExistingUser)
        } else { // if not, change last logged in value
            // assign to nil so that server can fill it in
            user!.lastLoggedInTimestamp = nil
            
            let _ = firestoreService.updateUser(user: user!)
        }
    }
}
