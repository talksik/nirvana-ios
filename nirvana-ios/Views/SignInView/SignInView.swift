//
//  SignInView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/13/21.
//

import SwiftUI
import Firebase
import FirebaseAuthUI

/* ... */

FirebaseApp.configure()
let authUI = FUIAuth.defaultAuthUI()
// You need to adopt a FUIAuthDelegate protocol to receive callback
authUI.delegate = self

struct SignInView: View {
    var body: some View {
        OnboardingTemplateView(hdrText: "Let's get started", imgName: "undraw_enter_uhqk", bottomActArea:
            AnyView(
                VStack(alignment: .center) {
                    NavigationLink(destination: HomeView()) {
                        Text("Sign Up")
                            .bold()
                            .foregroundColor(NirvanaColor.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                        
                    Button(
                        action: {
                            print("link to website learn more clicked")
                        },
                        label: {
                            Text("Learn More")
                                .bold()
                    })

                    //learn more button to usenirvana.com
                }
                .padding(.top, 20)
            )
        )
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
