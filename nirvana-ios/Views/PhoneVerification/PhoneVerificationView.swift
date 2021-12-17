//
//  PhoneVerificationView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/17/21.
//

import SwiftUI


// user can type in a phone number and then receive a text
struct PhoneVerificationView: View {
    @State var phoneNumber = ""
    
    
    var body: some View {
        ZStack {
            OnboardingTemplateView(hdrText: "Let's get you verified", imgName: "undraw_my_password_d-6-kg", bottomActArea: AnyView(
                VStack {
                    TextField("enter phone number", text: $phoneNumber)
                        .background(Color.white)
                    
                    Button {
                        print("send verification")
                        
                        
                    } label: {
                        Text("send verification")
                            .bold()
                            .foregroundColor(NirvanaColor.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                }
            ))
        }
    }
}

struct PhoneVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneVerificationView().environmentObject(AuthSessionStore())
    }
}

// another view for user to type in the sms code
struct PhoneVerificationCodeView: View {
    var body: some View {
        Text("Verification View")
    }
}

struct PhoneVerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneVerificationCodeView()
    }
}
