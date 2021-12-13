//
//  FooterControlsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/12/21.
//

import SwiftUI

struct FooterControlsView: View {
    @StateObject var viewModel:FooterControlsViewModel = FooterControlsViewModel()
    
    @GestureState var isPressingRecord: Bool = false
    @State var completedLongPress = false
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 1)
            .updating($isPressingRecord) { currentState, gestureState,
                    transaction in
                gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 2.0)
            }
            .onEnded { finished in
                print(finished)
                self.completedLongPress = finished
            }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Image(systemName: self.isPressingRecord ? "waveform" : "mic.fill")
                .foregroundColor(.white)
                .padding()
                .background(NirvanaColor.teal)
                .clipShape(Circle())
                .shadow(radius: 10)
                .gesture(longPress)
                .scaleEffect(x: self.isPressingRecord ? 1.2: 1,
                             y: self.isPressingRecord ? 1.2: 1,
                             anchor: .center)
        }
        .padding()
    }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
