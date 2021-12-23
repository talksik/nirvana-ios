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
    var senderIdReceiverIdComposite: [String]
    var listenCount: Int?
    var audioDataUrl:String
    
    @ServerTimestamp var sentTimestamp:Date?
    var firstListenTimestamp:Date?
   
    init(sendId: String, receivId: String, audioDUrl:String) {
        self.senderIdReceiverIdComposite = [sendId, receivId]
        self.senderId = sendId
        self.receiverId = receivId
        self.audioDataUrl = audioDUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case receiverId
        case senderId
        case senderIdReceiverIdComposite
        case listenCount
        case audioDataUrl
        case sentTimestamp
        case firstListenTimestamp
    }
}


