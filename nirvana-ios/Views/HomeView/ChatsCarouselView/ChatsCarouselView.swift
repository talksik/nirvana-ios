//
//  ChatsCarouselView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct ChatsCarouselView: View {
    var body: some View {
        mainCarouselView
    }
     
    var mainCarouselView: some View {
        TabView {
            ForEach(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                GeometryReader {proxy in
                    let minX = proxy.frame(in: .global).minX

                    carouselUser
                        .rotation3DEffect(.degrees(minX / -10), axis: (x: 0, y: 1, z: 0))
                        .shadow(color: Color("Shadow").opacity(0.3), radius: 10, x:0, y:10)
                        .blur(radius: abs(minX) / 40)

                    Text("\(minX)")
                }gi
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 400)
    }
    
    //the bottom navigation of the small profile pictures
//    var navigationCarouselView: some View { }
    
    var carouselUser: some View {
        Image("dummy_profile_picture")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(0)
            .clipShape(Circle())
    }
}

struct ChatsCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsCarouselView()
    }
}
