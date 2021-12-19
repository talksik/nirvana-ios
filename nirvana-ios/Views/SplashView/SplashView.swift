//
//  SplashView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI

struct SplashView: View {
    @State var scale = 1.0
    
    var body: some View {
        ZStack {
            HStack {
                Image("undraw_handcrafts_leaf")
                    .resizable()
                    .frame(width: 50, height: 75)
                    .foregroundColor(Color.white)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(NirvanaColor.teal)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView().environmentObject(AuthSessionStore())
    }
}
