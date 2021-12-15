//
//  Contact.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation
import Contacts

struct Contact: Identifiable, Hashable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phoneNumbers: [String]
    var emailAddresses: [String]
}

enum PermissionsError: Identifiable {
    var id: String { UUID().uuidString }
    case userError
    case fetchError(_: Error)
    var description: String {
        switch self {
        case .userError:
            return "Please change permissions in settings"
        case .fetchError(let error):
            return error.localizedDescription
        }
    }
    
}
