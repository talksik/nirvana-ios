//
//  FooterControlsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/12/21.
//

import SwiftUI

struct FooterControlsView: View {
    @StateObject var viewModel:FooterControlsViewModel = FooterControlsViewModel()
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Button {
                print("Button was pressed!")
            } label: {
                var icon:String = viewModel.isRecording ? "waveform" : "mic.fill"
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .padding()
                    .background(NirvanaColor.teal)
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
    }
}

struct FooterControlsView_Previews: PreviewProvider {
    static var previews: some View {
        FooterControlsView()
    }
}
