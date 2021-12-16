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
    
    let store: CNContactStore
    let keys: [CNKeyDescriptor]
    
    init() {
        store = CNContactStore()
        
        keys = [CNContactImageDataKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
    }
    
    func openSettings() {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) { UIApplication.shared.open(settingsURL)}
    }
    
    func requestAccess() {
        store.requestAccess(for: .contacts) {
            (granted, error) in
            return
        }
        // TODO do something useful with completionHandler
    }

    func fetchContacts(sortOrder: CNContactSortOrder = .userDefault) -> [CNContact] {
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        if authStatus == .notDetermined {
            requestAccess()
        } else if authStatus == .restricted {
            // TODO prompt user that app is useless without access to contacts
            self.showPermissionAlert = true
        }
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
        fetchRequest.sortOrder = sortOrder
        
        var fetchedContacts = [CNContact]()
        
        do {
            try store.enumerateContacts(with: fetchRequest) {
                (contact, stop) in
                fetchedContacts.append(contact)
            }
        } catch  {
            print("Unable to fetch contacts. \(error)")
            
        }
        
        return fetchedContacts
    }
}
