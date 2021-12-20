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
                    
                }
            }
            .searchable(text: $searchQuery)
            .listStyle(GroupedListStyle())
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
    var contact: CNContact
    
    @State var showAlert = false
    @State var alertText = ""
    @State var alertMessage = ""
    
    var body: some View {
        Button(action: {
            
        }) {
            HStack {
                Text("\(contact.familyName)").fontWeight(.bold)
                Text("\(contact.givenName) \(contact.middleName)")
                
                Spacer()
                
                // if the user is already an existing user
            }
            .foregroundColor(.black)
        }
        .alert(self.alertText, isPresented: self.$showAlert) {
            Button("OK", role: ButtonRole.cancel) { }
        } message: {
            Text(self.alertMessage)
        }
    }
}
