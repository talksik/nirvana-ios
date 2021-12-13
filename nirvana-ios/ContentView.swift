//
//  ContentView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

// dummy parent navigation page to test out all pages for now
struct ContentView: View {
//    @State private var selectedView: NavigationViews? = NavigationViews.welcomeView
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: WelcomeView()) {
                    Text("Welcome Page")
                }
                
                NavigationLink(destination: HomeView()) {
                    Text("Home Page")
                }
                
                NavigationLink(destination: WelcomeView()) {
                    Text("Onboarding - 1")
                }
            }
            .navigationBarTitle("View All Pages", displayMode: .inline)

        }
        
//        .navigationViewStyle(StackNavigationViewStyle())
//        .environmentObject()//can pass anything to send to all views within navigation view
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
