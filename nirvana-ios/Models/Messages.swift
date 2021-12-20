//
//  Messages.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Messages: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
    
    @ServerTimestamp var sentTimestamp:Date?
    @ServerTimestamp var listenedToTimestamp:Date?
    var audioDataUrl:String?
}


