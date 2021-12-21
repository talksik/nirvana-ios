//
//  Messages.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var receiverId: String
    var senderId: String
    var listenCount: Int
    var audioDataUrl:String?
    
    @ServerTimestamp var sentTimestamp:Date?
    var firstListenTimestamp:Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case receiverId
        case senderId
        case listenCount
        case audioDataUrl
        case sentTimestamp
        case firstListenTimestamp
    }
}


