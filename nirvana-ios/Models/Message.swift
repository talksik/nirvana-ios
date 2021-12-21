//
//  Messages.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var listenCount: Int
    var hasListened: Bool? = false
    var audioDataUrl:String?
    
    @ServerTimestamp var sentTimestamp:Date?
    @ServerTimestamp var firstListenTimestamp:Date?
}


