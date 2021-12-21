//
//  User.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var nickname: String?
    var phoneNumber: String?
    var emailAddress:String?
    var avatar:String?

    @ServerTimestamp var lastLoggedInTimestamp: Date?
    @ServerTimestamp var createdTimestamp: Date?
    
    // careful, if using codingkeys, you have to mapping every attribute thereafter
//    enum CodingKeys: String, CodingKey {
//        case id
//        case nickname
//        case phoneNumber
//        case emailAddress
//        case avatar
//        case lastLoggedInTimestamp
//        case createdTimestamp
//    }
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
