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
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            switch self.authSessionStore.sessionState {
            case SessionState.notCheckedYet:
                SplashView()
            case SessionState.isAuthenticated:
                InnerCircleView()
            case SessionState.isLoggedOut:
                WelcomeView()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive {
                print("user is offline")
                // set firestore user document isOnline to false
            } else if newPhase == .active {
                print("user is online again")
                // set firestore user document isOnline to true
            } else if newPhase == .background {
                print("app is in backgroun")
            }
        }
        
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView().environmentObject(AuthSessionStore())
    }
}
