//
//  SignInView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/13/21.
//

import SwiftUI
import Firebase
import AuthenticationServices
import GoogleSignIn

struct SignInView: View {
    @EnvironmentObject var authSessionStore: AuthSessionStore
    
    var body: some View {
        OnboardingTemplateView(hdrText: "Let's get started", imgName: "undraw_enter_uhqk", bottomActArea:
                    AnyView(
                        VStack(alignment: .center) {
//                            SignInWithAppleButton(.signIn,
//                                onRequest: { request in
//                                print("siginin in ")
//                            }, onCompletion: {result in
//                                print("signed in")
//                            })
//                                .frame(height:50)
//                                .clipShape(Capsule())
//                                .shadow(radius:20)
                            
                            Button {
                                self.handleLogin()
                            } label: {
                                HStack {
                                    Image("google")
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(NirvanaColor.white)
                                    
                                    Text("Continue with Google")
                                        .foregroundColor(NirvanaColor.white)
                                        .bold()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(NirvanaColor.teal)
                                .clipShape(Capsule())
                                .shadow(radius:10)
                            }
                            
                            
                            Text("By continuing, you are agreeing to our Terms of Service.")
                                .font(.callout.bold())
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                        }
                        .padding(.top, 20)
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                    )
                )
    }
    
    func handleLogin() {
        self.authSessionStore.signInOrCreateUser()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView().environmentObject(AuthSessionStore())
    }
}
