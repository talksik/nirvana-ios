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
    @Published var contacts: [String: ContactsViewModelContact] = [:]
    
    private var firestoreService = FirestoreService()
    
    let store: CNContactStore = CNContactStore()
    let keys: [CNKeyDescriptor] = [CNContactImageDataKey as CNKeyDescriptor,
                                   CNContactPhoneNumbersKey as CNKeyDescriptor,
                                   CNContactEmailAddressesKey as CNKeyDescriptor,
                                   CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
    
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
            try store.enumerateContacts(with: fetchRequest) {[weak self](contact, stop) in
                // only checking if american number or not for now
                var cnPhoneNumber = contact.phoneNumbers.first?.value.stringValue
                let contactDisplayName = contact.givenName + " " + contact.familyName
                // strip out nondigits
                // add or keep country code
                
                // TODO: take out hard coding to US country code
                var formattedNumber = cnPhoneNumber?.digits.suffix(10)
                
                // only show contacts if they have a phone number
                if formattedNumber != nil && formattedNumber?.count ?? 0 > 9 {
                    formattedNumber = "+1" + formattedNumber! // adding country code
                    
                    let contactNumber = String(formattedNumber!)
                    var contactVm = ContactsViewModelContact(cnName: contactDisplayName, cnPhoneNumber: contactNumber, sortingProp: contactDisplayName)
                    
                    // check if the contact is an existing user by phone number
                    self?.firestoreService.getUserByPhoneNumber(phoneNumber: contactNumber) {[weak self] returnedUser in
                        DispatchQueue.main.async {
                            if returnedUser == nil {
                                // do nothing, keep contactsVm object user property nil
                                contactVm.isExisting = false
                                contactVm.sortingProp = contactVm.cnName
                            } else {
                                // adding user details if this contact is existing user
                                // TODO: BUGGGG replaces each existing contact this way...need to keep the key for the dict unique
                                contactVm.sortingProp = "!" + contactVm.cnName // adding for sorting purposes
                                contactVm.user = returnedUser
                                contactVm.isExisting = true
                                print("existing user: \(contactVm.cnName)")
                            }
                            
                            self?.contacts[contactVm.sortingProp] = contactVm
                            print(self?.contacts)
                        }
                    }
                }
            }
        } catch  {
            print("Unable to fetch contacts. \(error)")
            
        }
    }
    
    func addOrActivateFriendToCircle(userId: String, friendId: String) {
        // setting timestamps to nil to make sure that new server timestamp is set
        var userFriend = UserFriends(userId: userId, friendId: friendId, isActive: true, lastUpdatedTimestamp: nil, createdTimestamp: nil)
        
        self.firestoreService.createOrUpdateUserFriends(userFriend: userFriend) {[weak self] res in
            print(res)
        }
    }
}


struct ContactsViewModelContact : Identifiable {
    var id : String = UUID().uuidString
    var user: User?
    var cnName: String
    var cnPhoneNumber: String
    var isExisting: Bool = false
    var sortingProp: String
}
