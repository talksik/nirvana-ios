//
//  ContentView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authSession: AuthSessionStore
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: WelcomeView()) {
                    Text("Welcome Page")
                }
                
                NavigationLink(destination: HomeView()) {
                    Text("Home Page")
                }
            }
            .navigationBarTitle("View All Pages", displayMode: .inline)
        }.onAppear(perform: self.getUser)
        
//        .navigationViewStyle(StackNavigationViewStyle())
//        .environmentObject()//can pass anything to send to all views within navigation view
    }
    
    func getUser () {
        authSession.listen()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
