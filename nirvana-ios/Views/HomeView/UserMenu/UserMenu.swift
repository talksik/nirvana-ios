//
//  UserMenu.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import SwiftUI

struct UserMenuView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button("Press to dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
        .background(Color.black)
    }
}

struct UserMenuView_Previews: PreviewProvider {
    static var previews: some View {
        UserMenuView()
    }
}
