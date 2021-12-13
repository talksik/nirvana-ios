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
                
                print("started drag")
                
            }
            .onEnded {_ in
                self.isHolding = false
                
                print("ended drag")
                
            }
    }
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 1)
            .updating($isLongPressingRecord) { currentState, gestureState,
                    transaction in
                gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 2.0)
                
                self.isHolding = true
                
                print("started long press")
            }
            .onEnded { finished in
                print(finished)
                self.completedLongPress = finished
                
                self.isHolding = false
                
                print("ended long press")
            }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Image(systemName: self.isHolding ? "waveform" : "mic.fill")
                .foregroundColor(.white)
                .padding()
                .background(NirvanaColor.teal)
                .clipShape(Circle())
                .shadow(radius: 10)
                .gesture(longPress)
                .simultaneousGesture(dragGesture)
                .scaleEffect(x: self.isHolding ? 1.2: 1,
                             y: self.isHolding ? 1.2: 1,
                             anchor: .center)
            
            Text("currently is \(self.isHolding ? "recording": "not recording")")
        }
        .padding()
    }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
