//
//  ContactsViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/15/21.
//

import Foundation
import Contacts
import SwiftUI

final public class ContactsViewModel : ObservableObject {
    @Published var contacts : [Contact] = []
    @Published var permissionsError: PermissionsError? = .none
    
    init() {
        self.permissions()
    }
    
    func openSettings() {
        self.permissionsError = .none
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) { UIApplication.shared.open(settingsURL)}
    }
    
    private func fetchContacts() {
        //remove all current contacts from vm
        contacts.removeAll()
        
        let store = CNContactStore()
        
        do {
            let predicate = CNContact.predicateForContacts(matchingName: "sarth")
            //specific contact details: ex: name, email, etc.
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]

            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            
            print("Fetched contacts: \(contacts)")
        } catch {
            print("Failed to fetch contacts, error: \(error)")
            // Handle the error
            self.permissionsError = .fetchError(error)
        }
    }
    
    private func permissions() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case.authorized:
            print("fetching contacts")
            fetchContacts()
        case .notDetermined, .restricted, .denied:
            CNContactStore().requestAccess(for: .contacts) {granted, error in
                switch granted {
                case true:
                    self.fetchContacts()
                case false:
                    DispatchQueue.main.async {
                        print("unable to get contacts")
                        self.permissionsError = .userError
                    }
                }
            }
        default:
            fatalError("Unknown Error!")
        }
    }
}
