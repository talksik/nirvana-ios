//
//  ProfilePicturesOverlappedView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/30/21.
//

import SwiftUI

struct ProfilePicturesOverlappedView: View {
    let numberAttendees:Int = 5
    let offset:Int = 15
    
    var indvAvatarWidth: CGFloat = 50
    
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
                        .frame(width: indvAvatarWidth)
                }
            }
            
        }
    }
}

struct ProfilePicturesOverlappedView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicturesOverlappedView()
    }
}
