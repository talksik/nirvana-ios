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
                    .scaleEffect(self.scale)
                    .animation(.easeIn(duration: 2).repeatForever(autoreverses: true))
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(NirvanaColor.teal)
        .onAppear {
            self.scale = 1.3
        }
        .ignoresSafeArea(.all)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
