//
//  User.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation
import SwiftUI

struct User: Identifiable, Hashable {
    var id:String = UUID().uuidString
    var email:String?
    var displayName:String?
    var profilePictureUrl:URL?
    var phoneNumber:String?
    
    init(_uid:String = UUID().uuidString, _email:String?, _displayName:String?, _profilePic:URL?, _phoneNumber: String?) {
        self.id = _uid
        self.email = _email
        self.profilePictureUrl = _profilePic
        self.displayName = _displayName
        self.phoneNumber = _phoneNumber
    }
}


struct TestUser: Identifiable, Hashable {
    var id = UUID().uuidString
    
    var profilePictureUrl:String
    var firstName:String
    var lastName:String
    var name:String?
    
    init(_id:String = UUID().uuidString, _profilePic:String, _firstN:String, _lastN:String) {
        self.id = _id
        self.profilePictureUrl = _profilePic
        self.firstName = _firstN
        self.lastName = _lastN
    }
}
