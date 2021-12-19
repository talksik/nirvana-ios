//
//  PhoneCodeVerificationView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/18/21.
//

import SwiftUI
import NavigationStack
import Combine
import Firebase
import FirebaseAuth

struct PhoneCodeVerificationView: View {
    @ObservedObject private var phoneverificationViewModel = PhoneVerificationViewModel()
    @EnvironmentObject private var navigationStack: NavigationStack
    
    @State var verificationCode = ""
    
    // Alert settings
    @State var showToast = false
    @State var toastText = ""
    @State var toastSubMessage = ""
    
    @State var isLoading = false
    
    @FocusState private var focusedInputField: Bool
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            OnboardingTemplateView(hdrText: "Let's get you verified", imgName: "undraw_my_password_d-6-kg", bottomActArea: AnyView(
                VStack {
                    TextField("Code", text: self.$verificationCode)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 20)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                        .keyboardType(.phonePad)
                        .focused(self.$focusedInputField)
                                        
                    
                    if self.verificationCode.count == 6 {
                        Button {
                            print("started verification process of code")
                            
                            //disable focused textfield
                            self.focusedInputField.toggle()
                            
                            // show loading screen
                            self.isLoading.toggle()
                            
                            
                            // TODO: do all of this in view model authstore
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
                                // done with the response here, turn off loading screen
                                self.isLoading.toggle()
                                
                                if err != nil {
                                    self.toastText = "⚠️ Error with Verification"
                                    self.toastSubMessage = "Code is invalid. Please try again or re-enter your phone number in the previous page."
                                    self.showToast.toggle()
                                    
                                    print((err?.localizedDescription)!)
                                    return
                                }
                                
                                //setting in key storage
                                UserDefaults.standard.set(true, forKey: "authVerificationID")
                                
                                // firebase either created a new user or is giving back an existing user's id
                                let userId = res?.user.uid
                                let userPhoneNumber = res?.user.phoneNumber
                                print("user id that was authenticated is: \(userId)")
                                print("user id that was authenticated is: \(userPhoneNumber)")
                                
                                // if for some reason firebase couldn't get basic user details
                                if userId == nil || userPhoneNumber == nil {
                                    self.toastText = "⚠️ Error with Verification"
                                    self.toastSubMessage = "Code is invalid. Please try again or re-enter your phone number in the previous page."
                                    self.showToast.toggle()
                                    
                                    print((err?.localizedDescription)!)
                                    return
                                }
                                
                                self.phoneverificationViewModel.createOrUpdateUser(userId: userId!, phoneNumber: userPhoneNumber!)
                                
                                // then sending to next page
                                self.navigationStack.push(OnboardingTrioView()) // verify code page
                            }
                            
                        } label: {
                            Text("Verify")
                                .bold()
                                .foregroundColor(NirvanaColor.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(NirvanaColor.teal)
                                .clipShape(Capsule())
                                .shadow(radius:10)
                        }
                    } else {
                        Text("Verify")
                            .foregroundColor(Color.white.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white.opacity(0.2)) // show dull button if didn't enter full phone number
                            .clipShape(Capsule())
                            .shadow(radius:10)
                            .animation(.default)
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
            
            if self.isLoading {
                SplashView()
            }
        }
        .alert(self.toastText, isPresented: self.$showToast) {
            
            Button("OK", role: ButtonRole.cancel) { }
            
        } message: {
            Text(self.toastSubMessage)
        }
    }
}

struct PhoneCodeVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneCodeVerificationView().environmentObject(AuthSessionStore())
    }
}
