//
//  LogoHeaderView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI

struct LogoHeaderView: View {
    var body: some View {
        HStack {
            Image("undraw_handcrafts_leaf")
                .resizable()
                .frame(width: 20.0, height: 32.132)
            
            Text("nirvana")
                .font(Font.custom("Satisfy-Regular", size: 35))
                .foregroundColor(NirvanaColor.teal)
                .multilineTextAlignment(.center)
        }
    }
}

struct LogoHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LogoHeaderView()
    }
}
