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
    
    
    private func getScale(proxy: GeometryProxy) -> CGFloat {
        let scale:CGFloat = 2
        
        return scale
    }
    
    func getSelectedUser(userId: String) -> User {
        return self.viewModel.carouselUsers.filter{user in
            return user.id == userId
        }[0]
    }
     
    var body: some View {
        VStack {
            // main big carousel
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
            .padding(.top, 50)
            .onAppear {
                self.selectedUserId = self.viewModel.carouselUsers.first?.id ?? ""
            }
            
            // Bottom navigation carousel
            ScrollViewReader {proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.carouselUsers) {user in
                            let isSelected = user.id == self.selectedUserId
//                            let isLeftOrRight = !isSelected &&
                            
                            Image(user.profilePictureUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .cornerRadius(12)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                                .scaleEffect(isSelected ? 1 : 0.7)
                                .blur(radius: isSelected ? 0 : 0.9)
                                .padding(25)
                                .id(user.id)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedUserId = user.id
                                    }
                                }
                                .frame(minWidth: 100)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .padding(.vertical, 40)
                    
                }
                .onChange(of: self.selectedUserId) { _ in
                    withAnimation {
                        proxy.scrollTo(self.selectedUserId, anchor: .bottom)
                    }
                }
            }
            
            Spacer()
        }
    }
    
    //the bottom navigation of the small profile pictures
//    var navigationCarouselView: some View { }
    
}

struct ChatsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

