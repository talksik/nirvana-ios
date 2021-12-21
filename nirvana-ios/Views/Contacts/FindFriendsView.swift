//
//  FindFriendsView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/20/21.
//

import SwiftUI
import Contacts



struct FindFriendsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var contactsVM = ContactsViewModel()
    
    @State private var searchQuery: String = ""

    
    var body: some View {
        NavigationView {
            // list with search bar
            List {
                ForEach(contactsVM.contacts.sorted { $0.isExisting && !$1.isExisting }) { contact in
                    ListContactRow(contact: contact)
                }
            }
            .navigationTitle("Find Friends")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }, label: {
                Text("Cancel")
            }))
        }
        .onAppear  {
            // organize contacts
            // sort by has account and then show all other contacts
            
        }
    }
}

struct FindFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FindFriendsView().environmentObject(AuthSessionStore())
    }
}

struct ListContactRow: View {
    var contact: ContactsViewModelContact
    
    @State var showAlert = false
    @State var alertText = ""
    @State var alertMessage = ""
    
    var body: some View {
        if contact.isExisting { // add to circle
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
                    print("adding contact to circle")
                    
                    //show alert if circle is full
                    
                } label: {
                    Label("Add", systemImage: "plus.circle")
                        .font(.title2)
                        .foregroundColor(NirvanaColor.solidTeal)
                }
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
                } label: {
                    Label("Invite", systemImage: "paperplane")
                        .font(.title2)
                        .foregroundColor(Color.orange)
                }
            }
        }
    }
}
