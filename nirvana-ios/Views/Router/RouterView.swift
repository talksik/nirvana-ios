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
        SplashView()
        .onReceive(self.authSessionStore.$user) {updatedUserFromAuth in // observing user because takes longer to get the user details than see updates to sessionstate and we need the user for the logic below
            print("figuring out where to send the user based on state: \(self.authSessionStore.sessionState)")
            if self.authSessionStore.sessionState == SessionState.isAuthenticated && updatedUserFromAuth != nil {
                print("user stored in authsession store: \(updatedUserFromAuth)")
                // evaluate where the user should go based on how much data he has
                
                // user is authenticated but has never picked a username or avatar
                if updatedUserFromAuth?.nickname != nil && updatedUserFromAuth?.avatar != nil {
                    self.navigationStack.push(OnboardingTrioView())
                } else {// user is existing user/up and running user -> signs in is pushed nicely right to hub
                    self.navigationStack.push(InnerCircleView())
                }
            } else {
                print("sending user to welcome view")
                // go to welcome page at which point they can go and follow the programmatic
                // line to the sigin and so on and so forth
                self.navigationStack.push(WelcomeView())
            }
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView().environmentObject(AuthSessionStore())
    }
}
