//
//  Onboarding.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI

struct WelcomeView: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
            OnboardingTemplateView(imgName: "undraw_friendship_mni7", mainLeadingActText: "Your", mainHighlightedActText: "minimalist", mainTrailingActText: "social media.", subActText: "Tired of the rat race on insta, snap, tik-tok, \"meta\"?", bottomActArea: AnyView(
                    VStack(alignment: .center) {
                        NavigationLink(destination: HomeView()) {
                            Text("Start Your Detox")
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
    } // View body
} // View


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}



