//
//  ContentView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI
import NavigationStack

struct ContentView: View {
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    // welcome -> phone verification -> phone code verification -> onboarding trio -> first, last, avatar picker -> add contacts -> hub
    var body: some View {
        NavigationStackView {
            AddBasicInfoView()
            // TODO: remove this commenting to enable natural user flow
//            switch self.authSessionStore.sessionState {
//                case SessionState.isAuthenticated:
//                    InnerCircleView()
//                case SessionState.isLoggedOut:
//                    WelcomeView()
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthSessionStore())
    }
}
