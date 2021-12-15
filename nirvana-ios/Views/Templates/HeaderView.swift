//
//  Header.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var authStore:AuthSessionStore
    @State var averageColor: UIColor = UIColor(NirvanaColor.teal)
    @State var showingMenu: Bool = false
    
    var body: some View {
        if authStore.sessionState == SessionState.isLoggedOut {
            HStack {
                Image("undraw_handcrafts_leaf")
                    .resizable()
                    .frame(width: 20.0, height: 32.132)
                
                Text("nirvana")
                    .font(Font.custom("Satisfy-Regular", size: 35))
                    .foregroundColor(NirvanaColor.teal)
                    .multilineTextAlignment(.center)
            }
        } else {
            HStack(alignment:.center) {
                Image("undraw_handcrafts_leaf")
                    .resizable()
                    .frame(width: 20.0, height: 32.132)
                    .padding(.leading, 20)
                
                Spacer()
                
                Menu {
                    Button("Log out") {
                        print("log out button clicked")
                        self.authStore.logOut()
                    }
                    Button("Friends") {
                        print("manage friends page")
                    }
                } label: {
                    RemoteImage(url: self.authStore.user?.profilePictureUrl?.absoluteString ?? "https://avatars.githubusercontent.com/u/41487836")
                        .background(NirvanaColor.teal)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(5)
                }
            }
            .frame(maxWidth: .infinity)
    //        .background(Color(self.averageColor)) // color based on user's profilepicture dominant color
            .background(NirvanaColor.solidBlue)
            .cornerRadius(100)
            .padding(.horizontal)
            .shadow(radius: 10)
            .onAppear{
                // set background color based on profile picture tint
                if let userPicUrl = authStore.user?.profilePictureUrl {
                    if let avgColor = NirvanaImage.getAverageColor(url: userPicUrl.absoluteString) {
                        self.averageColor = avgColor
                    }
                }
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
