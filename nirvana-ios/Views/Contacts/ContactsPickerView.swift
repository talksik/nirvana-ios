//
//  ContactsPickerView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import SwiftUI
import Contacts

struct ContactPickerView: View {
    @Binding var showPicker: Bool
    // updates the parent view for it to do something with the new contact
    @Binding var selectedContact: CNContact?
    
    var contacts: [String: [CNContact]] = loadContactsGrouped()
    
    var body: some View {
        let keys = (Array(contacts.keys) as [String]).sorted()
        NavigationView {
            List {
                ForEach(keys.sorted(), id: \.self) { key in
                    Section(header: Text(key)) {
                        ForEach(contacts[key] ?? [CNContact](), id: \.identifier) { contact in
                            ContactRow(contact: contact, showPicker: self.$showPicker, selectedContact: self.$selectedContact)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("All Contacts".localized)
            .navigationBarItems(trailing: Button(action: {self.showPicker = false}, label: {
                Text("Cancel".localized)
            }))
        }
    }

    static func loadContactsGrouped() -> [String: [CNContact]] {
        let provider = ContactsViewModel()
        let contacts = provider.fetchContacts()
        
        let group = Dictionary(grouping: contacts) { (contact) -> String in
            return String(contact.familyName.first ?? "?")
        }
        
        return group
    }
}


struct ContactRow: View {
    var contact: CNContact
    @Binding var showPicker: Bool
    @Binding var selectedContact: CNContact?
    
    var body: some View {
        Button(action: {
            selectContact()
        }) {
            HStack {
                Text("\(contact.familyName)").fontWeight(.bold)
                Text("\(contact.givenName) \(contact.middleName)")
            }
            .foregroundColor(.black)
        }
    }
    
    func selectContact() {
        self.selectedContact = self.contact
        self.showPicker = false
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
