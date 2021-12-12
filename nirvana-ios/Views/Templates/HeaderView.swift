//
//  Header.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct HeaderView: View {
    var isAuthenticated:Bool = false
    
    init(isAuth:Bool = false) {
        self.isAuthenticated = isAuth
    }
    
    var body: some View {
        HStack(alignment:.center) {
            if (self.isAuthenticated) {
                Image(systemName: "list.bullet.circle")
                    .font(Font.system(.largeTitle))
                    .padding()
                    .foregroundColor(NirvanaColor.teal)
                
            }
            
            Spacer()
            
            HStack {
                Image("undraw_handcrafts_leaf")
                    .resizable()
                    .frame(width: 20.0, height: 32.132)
                    
                Text("nirvana")
                    .font(Font.custom("Satisfy-Regular", size: 35))
                    .foregroundColor(NirvanaColor.teal)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            if (self.isAuthenticated) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(Font.system(.largeTitle))
                    .padding()
                    .foregroundColor(NirvanaColor.teal)
            }
                
        }
        .frame(maxWidth: .infinity)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(isAuth:true)
    }
}
