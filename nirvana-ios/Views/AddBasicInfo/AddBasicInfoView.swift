//
//  AddBasicInfoView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI

struct AddBasicInfoView: View {
    var body: some View {
        ZStack {
            // bg
            WavesGlassBackgroundView()
            
            // programmatic back button
            ZStack(alignment: .topLeading) {
                Color.clear
                
                Button {
                    
                } label: {
                    Label("back", systemImage:"chevron.left")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
                .padding()
            }
            
            // all content top down
            VStack {
                LogoHeaderView()
                
                Spacer()
            }
        }
    }
}

struct AddBasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AddBasicInfoView().environmentObject(AuthSessionStore())
    }
}
