//
//  Messages.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation

public struct Messages: Codable {
    let id: String
    let senderId: String
    let receiverId: String
    
    let sentTimestamp:Date
    let listenedTimestamp:Date
    let audioDataUrl:String
}


