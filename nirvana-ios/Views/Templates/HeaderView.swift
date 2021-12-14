//
//  Header.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var authStore:AuthSessionStore
    
    var body: some View {
        HStack(alignment:.center) {
            if self.authStore.sessionState == SessionState.isAuthenticated {
                Image(systemName: "list.bullet.circle")
                    .font(Font.system(.largeTitle))
                    .padding()
                    .foregroundColor(NirvanaColor.teal)
            }
            
            Spacer()
            
            HStack {
                Image("undraw_handcrafts_leaf")
                    .resizable()
                    .frame(width: 20.0, height: 32.132)
                    
                Text("nirvana")
                    .font(Font.custom("Satisfy-Regular", size: 35))
                    .foregroundColor(NirvanaColor.teal)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            if self.authStore.sessionState == SessionState.isAuthenticated {
                RemoteImage(url: "https://avatars.githubusercontent.com/u/41487836")
                    .background(NirvanaColor.teal)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView().environmentObject(AuthSessionStore())
    }
}
