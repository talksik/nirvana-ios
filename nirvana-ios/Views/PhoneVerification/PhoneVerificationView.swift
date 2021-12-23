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
    
    @State var isLoading = false
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    @FocusState private var focusedInputField: Bool
    
    
    @State var navigateNext = false
    
    // TODO: format the input so that it shows the parentheses and stuff (949)923-0445
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            
            OnboardingTemplateView(hdrText: "Let's get you verified", imgName: "undraw_off_road_-9-oae", bottomActArea: AnyView(
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
                        
                        TextField("(650) 555 - 1234", text: self.$phoneNumber)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .keyboardType(.phonePad)
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
                            .focused(self.$focusedInputField)
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    
                    // did they input a 10 digit number?
                    if self.phoneNumber.count == 10 {
                        Button {
                            let concatPhoneNumber = "+"+self.ccode+self.phoneNumber
                            
                            //disable focused textfield...important: draw the focus field out first and then the loading screen
                            self.focusedInputField = false
                            
                            //show loading screen
                            self.isLoading.toggle()
                            
                            print("sending sms and/or redirecting")
                            
                            // TODO: do all of this in view model
                            // do auth stuff from firebase
                            PhoneAuthProvider.provider()
                              .verifyPhoneNumber(concatPhoneNumber, uiDelegate: nil) {verificationID, error in
                                  print("firebase auth done, now running my callback")
                                  
                                  // problem verifying number showing alert...maybe fake number or something from user
                                  if error != nil {
                                      // turn off loading page...have an error to show
                                      self.isLoading.toggle()
                                      
                                      self.toastText = "⚠️ Please try again."
                                      self.toastSubMessage = "There was an issue validating your phone number"
                                      self.showToast.toggle()
                                      
                                      print((error?.localizedDescription)!)
                                      
                                      return
                                  }
                                  
                                  // use this in the next screen to verify with the code provided
                                  UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                                  
                                  self.navigationStack.push(PhoneCodeVerificationView()) // verify code page
                              }
                        } label: {
                            VStack {
                                Text("Send Verification")
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(NirvanaColor.teal)
                                    .clipShape(Capsule())
                                    .shadow(radius:10)
                                    .animation(.default)
                                
                                Text("You might receive an SMS message for verification and standard rates apply.")
                                    .font(.caption)
                                    .foregroundColor(NirvanaColor.teal)
                            }
                        }
                    } else { // show dull button if didn't enter full phone number
                        Text("Send Verification")
                            .foregroundColor(Color.white.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.white.opacity(0.2))
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
//
struct PhoneVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneVerificationView().environmentObject(AuthSessionStore())
    }
}


