//
//  ConvosView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import SwiftUI

struct ConvosView: View {
    @EnvironmentObject var vm: ConvoViewModel
    @State var animate = false
    
    var body: some View {
        ScrollView([.horizontal]) {
            HStack {
                ForEach(0..<self.vm.relevantConvos.count, id: \.self) {index in
                    let currConvo = self.vm.relevantConvos[index]
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .foregroundColor(self.vm.selectedConvoId == currConvo.id ? Color.green : NirvanaColor.dimTeal.opacity(0.2))
                                                        
                        ZStack {
                            Color.clear
                            ProfilePicturesOverlappedView()
                                .shadow(radius: 10)
                        }
                        
                        Text("+2")
                            .padding(5)
                            .font(.caption)
                            .foregroundColor(Color.white)
                            .background(NirvanaColor.dimTeal)
                            .cornerRadius(100)
                        
//                        ZStack(alignment: .bottom) {
//                            Color.clear
//
//                            Text("kev, sarth...")
//                                .foregroundColor(NirvanaColor.teal)
//                                .font(.caption)
//                        }
                    }
                    .frame(width: 100, height: 100)
                    .scaleEffect(self.animate ? 1 : 0.85)
                    .animation(
                        Animation.easeInOut(duration: self.vm.selectedConvoId == currConvo.id ? 2 : 4
                                           ).repeatForever(autoreverses: true),
                       value: self.animate
                    )
                    .onTapGesture {
                        // if not in a call already
                        if !self.vm.isInCall() {
                            self.vm.selectedConvoId = self.vm.relevantConvos[index].id!
                            self.vm.joinConvo(convoId: currConvo.id!)
                            
                            return
                        }
                        
                        self.vm.leaveConvo()
                    }
                }
            }
            .onAppear {
                self.animate = true
            }
        }
        .padding()
    }
}

//struct ConvosView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConvosView()
//    }
//}
