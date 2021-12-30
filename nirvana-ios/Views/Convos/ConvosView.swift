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
                ForEach(0..<self.vm.testConvos.count, id: \.self) {index in
                    let currConvo = self.vm.testConvos[index]
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .foregroundColor(self.vm.selectedConvoId == currConvo.id ? Color.green : NirvanaColor.dimTeal.opacity(0.2))
                                                        
                        ZStack {
                            Color.clear
                            ProfilePictureOverlap()
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
                            self.vm.selectedConvoId = self.vm.testConvos[index].id!
                            self.vm.joinConvo()
                            
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

struct ProfilePictureOverlap: View {
    let numberAttendees:Int = 5
    let offset:Int = 15
    
    var body: some View {
        ZStack {
            ForEach(0..<numberAttendees, id: \.self) {attendeeIndex in
                if attendeeIndex < 3 {
                    Image(Avatars.avatarSystemNames[attendeeIndex+1])
                        .resizable()
                        .scaledToFit()
                        .background(NirvanaColor.dimTeal)
                        .clipShape(Circle())
                        .offset(x: CGFloat((-15 * attendeeIndex)) + 15)
                        .frame(width: 50)
                }
            }
            
        }
    }
}
