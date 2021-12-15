//
//  ContactsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import SwiftUI

struct ContactsView: View {
    var testUsers:[TestUser] = [
        TestUser(_profilePic: "liam", _firstN: "Liam", _lastN: "Digregorio"),
        TestUser(_profilePic: "heran", _firstN: "Heran", _lastN: "Patel"),
        TestUser(_profilePic: "sarth", _firstN: "Sarth", _lastN: "Shah"),
        TestUser(_profilePic: "kevin", _firstN: "Kevin", _lastN: "Le"),
        TestUser(_profilePic: "rohan", _firstN: "Rohan", _lastN: "Chadha")
    ]
    
    var body: some View {
        List {
            ForEach(testUsers) { user in
                let fullName = "\(user.firstName) \(user.lastName)"
                IndividualContactView(name: fullName, imageName: user.profilePictureUrl)
            }
        }
    }
    
    
}

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsView().environmentObject(AuthSessionStore())
    }
}

private struct IndividualContactView: View {
    var name: String
    var imageName: String
    
    @Namespace private var animation
    @State var addedUser = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)
            
            Text(name)
                .font(.headline)
            
            Spacer()
            
            VStack {
                if addedUser {
                    Label("Added", systemImage: "person.crop.circle.fill.badge.checkmark")
                        .font(.title2)
                        .foregroundColor(NirvanaColor.solidTeal)
                        .labelStyle(IconOnlyLabelStyle())
                        .matchedGeometryEffect(id: "add-contact", in: animation)
                } else {
                    Button {
                        print("pressed add button")
                    } label: {
                        Label("Add", systemImage: "plus.circle")
                            .font(.title2)
                            .foregroundColor(NirvanaColor.solidTeal)
                            .labelStyle(IconOnlyLabelStyle())
                            .matchedGeometryEffect(id: "add-contact", in: animation)
                    }
                }
            }.onTapGesture {
                withAnimation(Animation.interpolatingSpring(stiffness: 300, damping: 30)) {
                    self.addedUser.toggle()
                }
            }
        }
    }
}
