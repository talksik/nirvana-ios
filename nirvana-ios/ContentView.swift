//
//  ContentView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    var body: some View {
        ZStack {
            switch self.authSessionStore.sessionState {
                case SessionState.isAuthenticated:
                    HomeView()
                case SessionState.isLoggedOut:
                    WelcomeView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthSessionStore())
    }
}
