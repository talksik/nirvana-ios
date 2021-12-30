//
//  Convo.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

enum ConvoState: String, Codable {
    case connected
    case disconnected
}

struct Convo: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var leaderUserId: String
    var receiverUserId: String
    
    var agoraToken: String
    
    var state: ConvoState
    
    var Users: [String]?
    
    @ServerTimestamp var startedTimestamp: Date?
    @ServerTimestamp var endedTimestamp: Date?
}

//struct DetailConvo: Convo {
//    func getRelativeStartTime() {
//        
//    }
//}
