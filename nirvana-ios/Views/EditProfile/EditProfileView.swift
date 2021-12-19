//
//  EditProfileView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI
import NavigationStack

struct EditProfileView: View {
    @EnvironmentObject var navigationStack: NavigationStack
    
    var body: some View {
        Button {
            self.navigationStack.push(ContactsView())
        } label: {
            
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
