//
//  PhoneVerificationView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/17/21.
//

import SwiftUI
import NavigationStack

// user can type in a phone number and then receive a text
struct PhoneVerificationView: View {
    @State var phoneNumber = ""
    @State var ccode = "+1"
    @EnvironmentObject private var navigationStack: NavigationStack
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            OnboardingTemplateView(hdrText: "Let's get you verified", imgName: "undraw_my_password_d-6-kg", bottomActArea: AnyView(
                VStack {
                    HStack {
                        Text(ccode)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                        
                        TextField("enter phone number", text: $phoneNumber)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: .infinity)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                            .font(.caption)
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    Button {
                        print("send verification")
                        
                        // do auth stuff
                        // then async send to next page
                        self.navigationStack.push(PhoneVerificationCodeView()) // verify code page
                        
                    } label: {
                        Text("Send Verification")
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
            
            //back button to home
            Button {
                print("going back to last page")
                
                self.navigationStack.pop() // goes back to welcome screen
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .foregroundColor(NirvanaColor.teal)
                    .padding()
            }
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
