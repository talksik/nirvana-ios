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
                    )
                )
    }
    
    func handleLogin() {
        //Google sign in
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // create google sign in configuration object
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController())
            {[self] user, err in
                
                if let error = err {
                    print(err)
                    return
                }
                
                guard
                  let authentication = user?.authentication,
                  let idToken = authentication.idToken
                else {
                  return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    guard let user = result?.user else {
                        return
                    }
                    
                    print(user.displayName ?? "Success!")
                    print(user.photoURL)
                    print(user.phoneNumber)
                    // User is signed in
                    // ...
                }
            }
    }
    
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

extension View {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .init() }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
