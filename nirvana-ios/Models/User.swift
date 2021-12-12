//
//  User.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation
import SwiftUI

class User: Identifiable {
    var id = UUID()
    var profilePictureUrl:String = ""
    var firstName:String = ""
    var lastName:String = ""
    var name:String = ""
    
}
