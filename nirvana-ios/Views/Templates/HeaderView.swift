//
//  Header.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var authStore:AuthSessionStore
    @State var averageColor: UIColor? = UIColor(NirvanaColor.teal)
    
    var body: some View {
        HStack(alignment:.center) {
            Image("undraw_handcrafts_leaf")
                .resizable()
                .frame(width: 20.0, height: 32.132)
                .padding(.leading, 20)
            
            Spacer()
            
            if self.authStore.sessionState == SessionState.isAuthenticated {
                RemoteImage(url: "https://avatars.githubusercontent.com/u/41487836")
                    .background(NirvanaColor.teal)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding()
                    .shadow(radius:5)
            }
        }
        .background(Color(self.averageColor!))
        .frame(maxWidth: .infinity)
        .onAppear{
            // set background color based on profile picture tint
            if authStore.sessionState == SessionState.isAuthenticated {
                if let userPicUrl = authStore.user?.profilePictureUrl {
                    self.averageColor = NirvanaImage.getAverageColor(url: userPicUrl)
                }
//                self.averageColor = NirvanaImage.getAverageColor(url: "https://avatars.githubusercontent.com/u/41487836")
            }
        }
    }
    
    private func setAverageColor() {
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView().environmentObject(AuthSessionStore())
    }
}
