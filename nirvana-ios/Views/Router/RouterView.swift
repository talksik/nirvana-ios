//
//  RouterView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI
import NavigationStack

enum NavigationPages {
    case welcome
    case auth
    case intro
    case createProfile
    case circle
}

struct RouterView: View {
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var navigationStack: NavigationStack
    
    var body: some View {
        switch self.authSessionStore.sessionState {
        case SessionState.notCheckedYet:
            SplashView()
        case SessionState.isAuthenticated:
            InnerCircleView()
        case SessionState.isLoggedOut:
            WelcomeView()
        }   
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView().environmentObject(AuthSessionStore())
    }
}
