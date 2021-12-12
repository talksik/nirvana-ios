//
//  User.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation
import SwiftUI

class User: Identifiable {
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
