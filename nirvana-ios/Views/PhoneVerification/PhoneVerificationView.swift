//
//  PhoneVerificationView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/17/21.
//

import SwiftUI
import NavigationStack
import Combine
import Firebase
import FirebaseAuth

// user can type in a phone number and then receive a text
struct PhoneVerificationView: View {
    @State var phoneNumber = ""
    @State var ccode = "1"
    @EnvironmentObject private var navigationStack: NavigationStack
    
    // Alert settings
    @State var showToast = false
    @State var toastText = ""
    @State var toastSubMessage = ""
    
    // TODO: format the input so that it shows the parentheses and stuff (949)923-0445
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            OnboardingTemplateView(hdrText: "Let's get you verified", imgName: "undraw_my_password_d-6-kg", bottomActArea: AnyView(
                VStack {
                    HStack {
                        Text("+\(ccode)")
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                            .font(.subheadline)
                            .onTapGesture {
                                // tell people that we only support the United States
                                self.toastText = "🇺🇸 Only U.S. supported, more countries coming soon!"
                                self.showToast.toggle()
                            }
                        
                        TextField("(650) 555 - 1234", text: $phoneNumber)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .keyboardType(.decimalPad)
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                            .font(.subheadline)
                            .onReceive(Just(self.phoneNumber)) {newValue in
                                let filtered = newValue.filter {
                                    "0123456789".contains($0)
                                }
                                if filtered != newValue {
                                    self.phoneNumber = filtered
                                }
                            }
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    Button {
                        let concatPhoneNumber = "+"+self.ccode+self.phoneNumber
                        
                        // do auth stuff from firebase
                        PhoneAuthProvider.provider()
                          .verifyPhoneNumber(concatPhoneNumber, uiDelegate: nil) { verificationID, error in
                              // problem verifying number showing alert...maybe fake number or something from user
                              if error != nil {
                                  self.toastText = "⚠️ Please try again."
                                  self.toastSubMessage = "There was an issue validating your phone number"
                                  self.showToast.toggle()
                                  
                                  print((error?.localizedDescription)!)
                                  
                                  return
                              }
                              
                              print("sending sms")
                              
                              // TODO: Sign in using the verificationID and the code sent to the user
                              // if there is no user with the phone number, then create one
                              
                              UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                              
                              // then async send to next page
                              // TODO: coming back after function end and then having 1 second before hitting this...need to use async and combine and all of that to make sure that the main thread is not affected and it's all smooth
                              self.navigationStack.push(PhoneVerificationCodeView()) // verify code page
                          }
                    } label: {
                        VStack {
                            Text("Send Verification")
                                .fontWeight(.heavy)
                                .foregroundColor(NirvanaColor.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(self.phoneNumber.count == 10 ? NirvanaColor.teal : Color.white.opacity(0.2)) // show dull button if didn't enter full phone number
                                .clipShape(Capsule())
                                .shadow(radius:10)
                                .animation(.default)
                            
                            Text("You might receive an SMS message for verification and standard rates apply.")
                                .font(.footnote)
                                .foregroundColor(Color.gray)
                        }
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
        .alert(self.toastText, isPresented: self.$showToast) {
            
            Button("OK", role: ButtonRole.cancel) { }
            
        } message: {
            Text(self.toastSubMessage)
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
    @EnvironmentObject private var navigationStack: NavigationStack
    
    @State var verificationCode = ""
    
    // Alert settings
    @State var showToast = false
    @State var toastText = ""
    @State var toastSubMessage = ""
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            OnboardingTemplateView(hdrText: "Let's get you verified", imgName: "undraw_my_password_d-6-kg", bottomActArea: AnyView(
                VStack {
                    TextField("Code", text: self.$verificationCode)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .keyboardType(.decimalPad)
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
//                        .onReceive(Just(self.$verificationCode)) { newValue in
//                            let filtered = newValue.filter { "0123456789".contains($0) }
//
//                            if filtered != newValue {
//                                self.verificationCode = filtered
//                            }
//                        }
                    
                    Button {
                        print("verify code")
                        
                        // do auth stuff
                        
                        // get it from the previous screen but from storage
                        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                        
                        if verificationID == nil {
                            self.toastText = "There was an error validating your code."
                            self.showToast.toggle()
                        }
                        // if we got a value, then continue with verifying their code
                        let credential = PhoneAuthProvider.provider().credential(
                          withVerificationID: verificationID!,
                          verificationCode: self.verificationCode
                        )
                        
                        // firebase will now verify the credential
                        Auth.auth().signIn(with: credential) { (res, err) in
                            if err != nil {
                                self.toastText = "⚠️ Error with Verification"
                                self.toastSubMessage = "Code is invalid. Please try again or re-enter your phone number in the previous page."
                                self.showToast.toggle()
                                
                                print((err?.localizedDescription)!)
                                return
                            }
                            
                            //setting in key storage
                            UserDefaults.standard.set(true, forKey: "authVerificationID")
                            
                            //TODO: is the auth listener going to find that this person signed in? idk test it
                            
                            // firebase either created a new user or is giving back an existing user's id
                            let userId = res?.user.uid
                            let userPhoneNumber = res?.user.phoneNumber
                            print("user id that was authenticated is: \(userId)")
                            print("user id that was authenticated is: \(userPhoneNumber)")
                        
                            
                            // then sending to next page
                            self.navigationStack.push(PhoneVerificationCodeView()) // verify code page
                        }
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
        .alert(self.toastText, isPresented: self.$showToast) {
            
            Button("OK", role: ButtonRole.cancel) { }
            
        } message: {
            Text(self.toastSubMessage)
        }
    }
}

struct PhoneVerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneVerificationCodeView().environmentObject(AuthSessionStore())
    }
}
