//
//  ContentView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI
import NavigationStack

struct ContentView: View {
    var body: some View {
        NavigationStackView {
            RouterView()        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AuthSessionStore())
    }
}
