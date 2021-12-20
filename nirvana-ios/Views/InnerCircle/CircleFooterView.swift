//
//  CircleFooterView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import NavigationStack

struct CircleFooterView: View {
    @EnvironmentObject var navigationStack: NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore

    
    var body: some View {
        // TODO: do cool animations with this footer background fill in while recording or playing a message
        ZStack(alignment:.bottomTrailing) {
            VStack(alignment:.center) {
                Spacer()
                
                HStack {
                    if self.selectedUserIndex != nil {
                        Image("Artboards_Diversity_Avatars_by_Netguru-\(self.selectedUserIndex! + 1)")
                            .resizable()
                            .scaledToFit()
                            .background(NirvanaColor.teal.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(5)
                    }
                    
                    
                    VStack (alignment: .leading) {
                        Text("Sarth Shah")
                            .font(.footnote)
                            .foregroundColor(NirvanaColor.light)
                        Text("sent 20 minutes ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Label("Replay", systemImage: "repeat.1.circle.fill")
                        .font(.title2)
                        .labelStyle(.iconOnly)
                        .foregroundColor(Color.orange)
                    
                    
                    Spacer(minLength: 65)
                }
                .frame(maxWidth: .infinity, maxHeight: 60) // 60 is the height of the footer control big circle
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 20)
            }
            
            FooterControlsView()
        }
        .padding()
        .offset(
            x:0,
            y:self.selectedUserIndex == nil ? 150 : 0
        )
        .animation(Animation.spring(), value: self.selectedUserIndex)
    }
}

struct CircleFooterView_Previews: PreviewProvider {
    static var previews: some View {
        CircleFooterView()
    }
}
