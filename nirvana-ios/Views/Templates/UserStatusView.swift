//
//  UserStatusView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 1/1/22.
//

import SwiftUI

struct UserStatusView: View {
    var status: UserStatus?
    var size: CGFloat = 10
    var padding: CGFloat = 0
    
    var body: some View {
        // user status
        switch self.status {
        case .online:
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(Color.green)
                .padding(padding)
        case .offline:
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(Color.red)
                .padding(padding)
        case .inConvo:
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(Color.orange)
                .padding(padding)
        default:
            EmptyView()
        }
    }
}

//struct UserStatusView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserStatusView()
//    }
//}
