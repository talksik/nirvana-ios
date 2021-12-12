//
//  MainVoiceChat.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            HeaderView(isAuth:true)
            
            ChatsCarouselView()
            
            Spacer()
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .accentColor(NirvanaColors.teal)
        .background(NirvanaColors.bgLightGrey)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}
