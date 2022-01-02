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
        case .inConvo:
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(Color.orange)
                .padding(padding)
        case .background:
            Circle()
                .frame(width: size, height: size)
                .foregroundColor(NirvanaColor.dimTeal)
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

struct UserStatusTextView {
    var status: UserStatus?
    
    var body: Text {
        switch self.status {
        case .online:
            return Text("online")
                .font(.caption2)
                .foregroundColor(Color.green)
        case .inConvo:
            return Text("in convo")
                .font(.caption2)
                .foregroundColor(Color.orange)
        case .background:
            return Text("idle")
                .font(.caption2)
                .foregroundColor(NirvanaColor.dimTeal)
        default:
            return Text("offline")
                .font(.caption2)
                .foregroundColor(Color.gray)
        }
    }
}
