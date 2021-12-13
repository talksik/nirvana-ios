//
//  FooterControlsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/12/21.
//

import SwiftUI

struct FooterControlsView: View {
    @StateObject var viewModel:FooterControlsViewModel = FooterControlsViewModel()
    
    @GestureState var isLongPressingRecord: Bool = false
    @State var isHolding = false
    @State var completedLongPress = false
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged {_ in
                self.isHolding = true
            }
            .onEnded {_ in
                self.isHolding = false
            }
    }
        
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Button(action: {
                
            }, label: {
                Image(systemName: self.isHolding ? "waveform" : "mic.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(NirvanaColor.teal)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .scaleEffect(x: self.isHolding ? 1.2: 1,
                                 y: self.isHolding ? 1.2: 1,
                                 anchor: .center)
                    .simultaneousGesture(dragGesture)
            })
        }
        .padding()
    }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
