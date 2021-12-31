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
    case initialized
    case active
    case complete
}

struct Convo: Identifiable, Codable {
    // channel name for agora's purposes
    @DocumentID var id: String? = UUID().uuidString
    
    var leaderUserId: String
    var receiverUserId: String
    
    var agoraToken: String
    
    var state: ConvoState
    
    var users: [String] = []
    
    @ServerTimestamp var startedTimestamp: Date?
    var endedTimestamp: Date?
}

//struct DetailConvo: Convo {
//    func getRelativeStartTime() {
//        
//    }
//}
