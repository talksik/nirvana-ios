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
            
            Button(action: {
                print("pressed button")
            }) {
                Image(systemName: viewModel.isRecording ? "waveform" : "mic.fill")
                    .foregroundColor(.white)
                    .padding()
                    .background(NirvanaColor.teal)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            
        }
        .padding()
    }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
