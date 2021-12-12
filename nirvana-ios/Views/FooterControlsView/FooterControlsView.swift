//
//  FooterControlsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/12/21.
//

import SwiftUI

struct FooterControlsView: View {
    @StateObject var viewModel:FooterControlsViewModel = FooterControlsViewModel()
    @State private var scaleValue = CGFloat(1)
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Image(systemName: viewModel.isRecording ? "waveform" : "mic.fill")
                .foregroundColor(.white)
                .padding()
                .background(NirvanaColor.teal)
                .clipShape(Circle())
                .shadow(radius: 10)
//                .scaleEffect(self.scaleValue)
                .onLongPressGesture {
                    
                }
                .animation(.linear(duration:2), value: viewModel.isRecording)
                .onTapGesture {
                    viewModel.onStartRecording()
                    print("tap gesture active")
                }
//                .onTapGesture(
//                    touchBegan: {
//                    withAnimation {
//                        self.scaleValue = 1.2
//                    }
//
//                    viewModel.onStartRecording()
//
//                    print("long press active")
//                }, touchEnd: {_ in
//                    withAnimation {
//                        self.scaleValue = 1.0
//                    }
//
//                    print("long press not active anymore")
//                }
                
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
