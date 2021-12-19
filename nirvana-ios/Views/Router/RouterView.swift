//
//  RouterView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI

// show the loading screen while we figure out where to send the user through the nav stack
struct RouterView: View {
    // if not authenticated -> push to welcome
    // if authenticated
    //    if no profile pic and name and all -> go through onboarding again
    //    if has everythign in place -> homeview and get talking/chatting
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView()
    }
}
