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
    }
    
    
    public func 
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
