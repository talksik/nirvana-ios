//
//  ContactsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import SwiftUI
import Contacts
import ContactsUI
import NavigationStack

struct ContactsView: View {
    @EnvironmentObject var navigationStack : NavigationStack
    
    var testUsers:[TestUser] = [
        TestUser(_profilePic: "liam", _firstN: "Liam", _lastN: "Digregorio"),
        TestUser(_profilePic: "heran", _firstN: "Heran", _lastN: "Patel"),
        TestUser(_profilePic: "sarth", _firstN: "Sarth", _lastN: "Shah"),
        TestUser(_profilePic: "kevin", _firstN: "Kevin", _lastN: "Le"),
        TestUser(_profilePic: "rohan", _firstN: "Rohan", _lastN: "Chadha")
    ]
    
    @State var showPicker = false
    @State var selectedContact: CNContact?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            OnboardingTemplateView(imgName: "undraw_grades_re_j7d6", mainLeadingActText: "Add your ", mainHighlightedActText: "closest folks.", mainTrailingActText: "", subActText: "besties, bf or gf, siblings, parents, etc.")
            
            Button(action: {
                self.showPicker = true
            }, label: {
                Label("Add Contacts", systemImage: "plus")
                    .frame(width: 50, height: 50, alignment: .center)
                    .labelStyle(.iconOnly)
                    .font(.largeTitle)
                    .foregroundColor(NirvanaColor.white)
                    .background(NirvanaColor.teal)
                    .padding(.vertical, 20)
                    .clipShape(Circle())
                    .shadow(radius:10)
            })
            
            Text(selectedContact != nil ? "Selected: \((selectedContact?.familyName)!) \((selectedContact?.givenName)!)" : "Nothing selected".localized)
            
            Button {
                self.navigationStack.push(InnerCircleView())
            } label: {
                Text("go to hub")
            }
            
            Spacer()
        }
        .sheet(isPresented: self.$showPicker) {
                ContactPickerView(showPicker: self.$showPicker, selectedContact: self.$selectedContact)
            }
        .padding()
        .background(NirvanaColor.bgLightGrey)
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
    @State var isAddedUser = false

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
                if isAddedUser {
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
                    self.isAddedUser.toggle()
                }
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
