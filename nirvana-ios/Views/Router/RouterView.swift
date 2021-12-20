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

// show the loading/splash screen while we figure out where to send the user through the nav stack

// if not authenticated -> push to welcome
// if authenticated
//    if no profile pic and name and all -> go through onboarding again
//    if has everythign in place -> homeview and get talking/chatting


// Purpose: want to use programmatic and maintain the same nav stack but take the user to the right place
struct RouterView: View {
    @EnvironmentObject var authSessionStore: AuthSessionStore
    @EnvironmentObject var navigationStack: NavigationStack
    
    var body: some View {
        // authenticated and have user's data
        if self.authSessionStore.sessionState == SessionState.isAuthenticated {
            if self.authSessionStore.user != nil {
                if self.authSessionStore.user?.nickname == nil && self.authSessionStore.user?.avatar == nil {
                    OnboardingTrioView()
                } else {// user is existing user/up and running user -> signs in is pushed nicely right to hub
                    InnerCircleView()
                }
            } else {
                OnboardingTrioView()
            }
            
        } else if self.authSessionStore.sessionState == SessionState.isLoggedOut {
            // go to welcome page at which point they can go and follow the programmatic
            // line to the sigin and so on and so forth
            WelcomeView()
        } else {
            SplashView()
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView().environmentObject(AuthSessionStore())
    }
}
