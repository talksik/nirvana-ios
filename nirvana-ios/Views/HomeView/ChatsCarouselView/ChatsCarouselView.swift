//
//  ChatsCarouselView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct ChatsCarouselView: View {
    @StateObject var viewModel:ChatsCarouselViewModel = ChatsCarouselViewModel()
    
    var body: some View {
        mainCarouselView
    }
     
    var mainCarouselView: some View {
        TabView {
            ForEach(viewModel.carouselUsers) { carouselUser in
                GeometryReader {proxy in
                    let minX = proxy.frame(in: .global).minX
                    
                        Image(carouselUser.profilePictureUrl)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .padding()
                            .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
                            .blur(radius: abs(minX) / 40)
                            
                    
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 400)
        .padding(.top, 50)
        .padding(.horizontal, 30)
        
    }
    
    //the bottom navigation of the small profile pictures
//    var navigationCarouselView: some View { }
    
}

struct ChatsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

