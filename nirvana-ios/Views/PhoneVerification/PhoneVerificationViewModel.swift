//
//  PhoneVerificationViewModel.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/17/21.
//

import Foundation
import FirebaseAuth

final class PhoneVerificationViewModel : ObservableObject  {
    
    public func verifyPhoneAndSendSMS(phoneNumber: String) {
        // TODO: do some string validation here
        // do auth stuff from firebase
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
              print("firebase auth done, now running my callback")
              
              // got a response...done loading... either error to show or next page
//              self.isLoading.toggle()
              
              // problem verifying number showing alert...maybe fake number or something from user
              if error != nil {
//                  self.toastText = "⚠️ Please try again."
//                  self.toastSubMessage = "There was an issue validating your phone number"
//                  self.showToast.toggle()
                  
                  print((error?.localizedDescription)!)
                  
                  return
              }
              
              // use this in the next screen to verify with the code provided
              UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
              
//              self.navigationStack.push(PhoneCodeVerificationView()) // verify code page
          }
    }
    
}

extension String {
    // custom function to give (949)920-0392 and get out the right thing
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
