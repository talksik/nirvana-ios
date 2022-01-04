//
//  AddBasicInfoViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/19/21.
//

import Foundation

enum ProfileRegistrationState {
    case successful
    case failed(String)
    case loading
    case na
}

class AddBasicInfoViewModel : ObservableObject {
    @Published var state: ProfileRegistrationState = .na
    private var firestoreService = FirestoreService()
    
    // - get user data current data
    // - save user selections
    func updateUser(currUser: User, completion: @escaping () -> Void) {
        // validations
        // make sure nickname is less than 25 characters for now
        
        self.state = .loading
        
        if currUser.nickname == nil || currUser.avatar == nil {
            self.state = .failed("Please make sure to select avatar and nickname 🙏")
            completion()
            return
        }
        if currUser.nickname!.count > 25 {
            self.state = .failed("Please use a simpler nickname less than 25 characters 🙏")
            completion()
            return
        }
        if !SystemImages.avatars.contains(currUser.avatar!) {
            self.state = .failed("Invalid avatar selected!")
            completion()
            return
        }
        
        // save in firestore
        self.firestoreService.updateUser(user: currUser) {res in
            print(res)
            
            switch res {
            case .success:
                self.state = .successful
            case .error(let error):
                self.state = .failed(error.description)
            }
            
            completion()
        }
    }
}
