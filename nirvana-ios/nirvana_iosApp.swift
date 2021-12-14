//
//  nirvana_iosApp.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct nirvana_iosApp: App {
    @StateObject var authSessionStore: AuthSessionStore = AuthSessionStore()
    
    init() {
        self.setupAuth()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(authSessionStore)
        }
    }
}

extension nirvana_iosApp {
    private func setupAuth() {
        FirebaseApp.configure()
    }
}
