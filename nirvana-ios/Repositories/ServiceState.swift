//
//  ServiceStates.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import Foundation

enum ServiceState {
    case error(ServiceError)
    case success(String)
}

struct ServiceError {
    let description: String
}
