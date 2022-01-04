//
//  ProfilePicturesOverlappedView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/30/21.
//

import SwiftUI

/**
 @return a view that overlaps the user avatars
 */
struct ProfilePicturesOverlappedView: View {
    let offset:Int = 15
    
    var indvAvatarWidth: CGFloat = 50
    
    var users: [User]
    
    var body: some View {
        ZStack {
            ForEach(0..<users.count, id: \.self) {userIndex in
                Image(users[userIndex].avatar ?? SystemImages.avatars[1])
                    .resizable()
                    .scaledToFit()
                    .background(NirvanaColor.dimTeal)
                    .clipShape(Circle())
                    .offset(x: CGFloat((-15 * userIndex)) + 15)
                    .frame(width: indvAvatarWidth)
            }
        }
    }
}

//struct ProfilePicturesOverlappedView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilePicturesOverlappedView()
//    }
//}
