//
//  UserFriends.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum UserFriendsState {
    case active
    case inactive
}

struct UserFriends: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var userId: String
    var friendId: String
    var isActive: Bool
    
    @ServerTimestamp var lastUpdatedTimestamp: Date?
    @ServerTimestamp var createdTimestamp: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case friendId
        case isActive
        case createdTimestamp
        case lastUpdatedTimestamp
    }
}
