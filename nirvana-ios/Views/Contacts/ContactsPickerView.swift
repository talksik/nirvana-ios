////
////  ContactsPickerView.swift
////  nirvana-ios
////
////  Created by Arjun Patel on 12/15/21.
////
//
//import SwiftUI
//import Contacts
//
//struct ContactsPickerView: View {
//    @Environment(\.dismiss) var dismiss
//
//    // updates the parent view for it to do something with the new contact
//    @State var selectedContact: CNContact?
//
//    var contacts: [String: [CNContact]] = loadContactsGrouped()
//
//    var body: some View {
//        let keys = (Array(contacts.keys) as [String]).sorted()
//        NavigationView {
//            List {
//                ForEach(keys.sorted(), id: \.self) { key in
//                    Section(header: Text(key)) {
//                        ForEach(contacts[key] ?? [CNContact](), id: \.identifier) { contact in
//                            ContactRow(contact: contact, selectedContact: self.$selectedContact)
//                        }
//                    }
//                }
//            }
//            .listStyle(GroupedListStyle())
//            .navigationTitle("All Contacts".localized)
//            .navigationBarItems(trailing: Button(action: {
//                dismiss()
//
//            }, label: {
//                Text("Cancel".localized)
//            }))
//        }
//    }
//
//    static func loadContactsGrouped() -> [String: [CNContact]] {
//        let provider = ContactsViewModel()
//        let contacts = provider.fetchContacts()
//        print(contacts)
//        let group = Dictionary(grouping: contacts) { (contact) -> String in
//            return String(contact.familyName.first ?? "?")
//        }
//
//        print(group)
//
//        return group
//    }
//}
//
//
//struct ContactRow: View {
//    var contact: CNContact
//    @Binding var selectedContact: CNContact?
//
//    var body: some View {
//        Button(action: {
//            selectContact()
//        }) {
//            HStack {
//                Text("\(contact.familyName)").fontWeight(.bold)
//                Text("\(contact.givenName) \(contact.middleName)")
//            }
//            .foregroundColor(.black)
//        }
//    }
//
//    func selectContact() {
//        self.selectedContact = self.contact
//    }
//}
//
//extension String {
//    var localized: String {
//        return NSLocalizedString(self, comment: "")
//    }
//}
