//
//  ContactsViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation
import Contacts
import SwiftUI

class ContactsViewModel : ObservableObject {
    @Published var showPermissionAlert = false
    @Published var contacts: [ContactsViewModelContact] = []
    
    private var firestoreService = FirestoreService()
    
    let store: CNContactStore = CNContactStore()
    let keys: [CNKeyDescriptor] = [CNContactImageDataKey as CNKeyDescriptor,
                                   CNContactPhoneNumbersKey as CNKeyDescriptor,
                                   CNContactEmailAddressesKey as CNKeyDescriptor,
                                   CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
    
    init() {
        self.fetchContacts()
    }
    
    func openSettings() {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) { UIApplication.shared.open(settingsURL)}
    }
    
    func requestAccess() {
        
        store.requestAccess(for: .contacts) {(granted, error) in
            // TODO: do something useful with completionHandler
            return
        }
    }

    func fetchContacts() {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        if authStatus == .notDetermined {
            requestAccess()
        } else if authStatus == .restricted {
            // TODO: prompt user that app is useless without access to contacts
            self.showPermissionAlert = true
        }
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        fetchRequest.sortOrder = .userDefault
        
        do {
            try store.enumerateContacts(with: fetchRequest) {(contact, stop) in
                // only checking if american number or not for now
                var cnPhoneNumber = contact.phoneNumbers.first?.value.stringValue
                let contactDisplayName = contact.givenName
                // strip out nondigits
                // add or keep country code
                
                // TODO: take out hard coding to US country code
                var formattedNumber = cnPhoneNumber?.digits.suffix(10)
                
                // only show contacts if they have a phone number
                if formattedNumber != nil {
                    formattedNumber = "+1" + formattedNumber! // adding country code
                    
                    let contactNumber = String(formattedNumber!)
                    var contactVm = ContactsViewModelContact(cnName: contactDisplayName, cnPhoneNumber: contactNumber)
                    
                    // check if the contact is an existing user by phone number
                    self.firestoreService.getUserByPhoneNumber(phoneNumber: contactNumber) {[weak self] returnedUser in
                        DispatchQueue.main.async {
                            if returnedUser == nil {
                                // do nothing, keep contactsVm object user property nil
                                contactVm.isExisting = false
                            } else {
                                // adding user details if this contact is existing user
                                contactVm.user = returnedUser
                                contactVm.isExisting = true
                            }
                            
                            self?.contacts.append(contactVm)
                        }
                    }
                }
            }
        } catch  {
            print("Unable to fetch contacts. \(error)")
            
        }
    }
}


struct ContactsViewModelContact : Identifiable {
    var id : String = UUID().uuidString
    var user: User?
    var cnName: String
    var cnPhoneNumber: String
    var isExisting: Bool = false
}
