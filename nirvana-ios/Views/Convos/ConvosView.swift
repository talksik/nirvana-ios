//
//  ConvosView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/29/21.
//

import SwiftUI

// test convos
let testConvos: [Convo] = [
    Convo(leaderUserId: "VWVPKCrNmMeZlkEeZxuJ0Wsgq0C3", receiverUserId: "zd6PpD3TmnQUDoy6noS9aZpuPWr1", agoraToken: "006c8dfd65deb5c4741bd564085627139d0IAAIlYcWj21zCp4jq/WS2BMaiMYlKSax7ohIjzBx1BtpWAx+f9gAAAAAEADQ943gX6LOYQEAAQBfos5h", state: .connected)
]

struct ConvosView: View {
    var body: some View {
        ScrollView([.horizontal]) {
            HStack {
                ForEach(0..<testConvos.count, id: \.self) {index in
                    
                    
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .foregroundColor(NirvanaColor.dimTeal.opacity(0.4))
                            
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
                    }
                    .frame(width: 100, height: 100)
                }
            }
        }
    }
}

struct ConvosView_Previews: PreviewProvider {
    static var previews: some View {
        ConvosView()
    }
}

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
