//
//  ChatsCarouselView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct ChatsCarouselView: View {
    @StateObject var viewModel:ChatsCarouselViewModel = ChatsCarouselViewModel()
    // current snapped/selected user
    @State var selectedUserId: String = ""
    @State var selectedUser: User?
    
    var body: some View {
        mainCarouselView
    }
    
    private func getScale(proxy: GeometryProxy) -> CGFloat {
        let scale:CGFloat = 2
        
        return scale
    }
    
    func getSelectedUser(userId: String) -> User {
        return self.viewModel.carouselUsers.filter{user in
            return user.id == userId
        }[0]
    }
     
    var mainCarouselView: some View {
        TabView(selection: $selectedUserId) {
            ForEach(viewModel.carouselUsers) { carouselUser in
                GeometryReader {proxy in
                    let minX = proxy.frame(in: .global).minX
                    let scale = getScale(proxy: proxy)
                    
                    Image(carouselUser.profilePictureUrl)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
                        .blur(radius: abs(minX) / 40)
                        .scaleEffect()
                        .padding(50)
                }
                .frame(width: UIScreen.main.bounds.width)
                .tag(carouselUser.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .padding(.vertical, 60)
        .overlay(
            ScrollViewReader{proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.carouselUsers) {user in
                            Image(user.profilePictureUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 60)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .frame(height: 80)
                .background(Color.blue)
            },
            
            alignment: .bottom
        )
        
    }
    
    //the bottom navigation of the small profile pictures
//    var navigationCarouselView: some View { }
    
}

struct ChatsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

