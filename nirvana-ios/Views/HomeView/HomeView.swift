//
//  MainVoiceChat.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView(isAuth:true)
            
            ChatsCarouselView()
            
            FooterControlsView()            
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .accentColor(NirvanaColor.teal)
        .background(NirvanaColor.bgLightGrey)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}
