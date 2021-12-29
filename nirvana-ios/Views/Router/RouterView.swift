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
                self.authSessionStore.updateUserStatus(userStatus: .offline)
            } else if newPhase == .active {
                print("user is online again")
                // set firestore user document isOnline to true
                self.authSessionStore.updateUserStatus(userStatus: .online)
            } else if newPhase == .background {
                // TODO: find a way to do this in the background so that people can call me and start talking even if it's in the background
                // but this may just not be possible, only with an actual call so to speak
                print("app is in backgroun")
                self.authSessionStore.updateUserStatus(userStatus: .background)
            }
        }
        
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView().environmentObject(AuthSessionStore())
    }
}
