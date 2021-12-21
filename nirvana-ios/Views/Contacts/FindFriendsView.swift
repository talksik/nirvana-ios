//
//  FindFriendsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import Contacts
import NavigationStack



struct FindFriendsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var contactsVM = ContactsViewModel()
    
    @State private var searchQuery: String = ""
    
    var body: some View {
        
        NavigationView {
            // TODO: add search bar + have secondary sort
            List {
                ForEach(searchItems, id: \.self) { key in
                    if let currContact = self.contactsVM.contacts[key] {
                        ListContactRow(contactsVM: self.contactsVM, contact: currContact)
                    }
                }
            }
            .searchable(text: self.$searchQuery)
            .navigationTitle("Find Friends")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }, label: {
                Text("Cancel")
            }))
        }
        .onAppear {
            self.contactsVM.fetchContacts()
        }
    }
    
    var searchItems: [String] {
        let keys = (Array(self.contactsVM.contacts.keys) as [String]).sorted()
        
        if self.searchQuery.isEmpty  {
            return keys
        } else {
            return keys.filter { $0.contains(self.searchQuery) }
        }
    }
    
    
}

struct FindFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FindFriendsView().environmentObject(AuthSessionStore())
    }
}

struct ListContactRow: View {
    @EnvironmentObject var navigationStack : NavigationStack
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    var contactsVM: ContactsViewModel
    var contact:ContactsViewModelContact
    
    @State var showAlert = false
    @State var alertText = "🌱Confirm Arjun into Your Circle?"
    @State var alertMessage = "Note: You can have a maximium of 12 people in your circle and you have 5 swaps left!"
    
    var body: some View {
        if contact.isExisting { // add to circle
            // TODO: check if this contact is already in user's circle
            HStack(alignment: .center, spacing: 0) {
                Image(contact.user?.avatar ?? Avatars.avatarSystemNames[1])
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 10)
                        
                Text(contact.cnName)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    print("showing alert now")
                    // TODO: show alert if circle is full
                    self.showAlert.toggle()
                    
                } label: {
                    Label("Add", systemImage: "plus.circle")
                        .font(.title2)
                        .foregroundColor(NirvanaColor.solidTeal)
                }
            }
            .alert(self.alertText, isPresented: self.$showAlert) {
                Button("Add \(contact.cnName)") {
                    print("adding contact to circle")
                    // call method in vm to get it done, then navigate to the circle
                    self.contactsVM.addOrActivateFriendToCircle(userId: self.authSessionStore.user!.id!, friendId: (contact.user!.id)!)
                   
                    self.navigationStack.push(InnerCircleView())
                }
            } message: {
                Text(self.alertMessage)
            }
        }
        else { // invite button to text the person
            HStack(alignment: .center, spacing: 0) {
                Image(Avatars.avatarSystemNames[1])
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .blur(radius: 8)
                    .padding(.trailing, 10)
                
                Text(contact.cnName)
                    .font(.headline)
                
                Spacer()
                
                Button {
                    print("inviting user now")
                    // text message to him/her
                    
                    if contact.cnPhoneNumber != nil {
                        let sms: String = "sms://\(contact.cnPhoneNumber)&body=Join me on Nirvana! I sent you a message there! https://usenirvana.com"
                        let strUrl: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        
                        UIApplication.shared.open(URL(string: strUrl)!, options: [:], completionHandler: nil)
                    } else {
                        print("phone number is nil of contact")
                    }
                } label: {
                    Label("Invite", systemImage: "paperplane")
                        .font(.title2)
                        .foregroundColor(Color.orange)
                }
            }
        }
    }
}


