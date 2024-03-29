//
//  Onboarding.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import SwiftUI
import NavigationStack

struct WelcomeView: View {
    @State var showLearnMore = false
    @EnvironmentObject private var navigationStack: NavigationStack
    
    var body: some View {
        OnboardingTemplateView(imgName: "undraw_friendship_mni7", mainLeadingActText: "Your", mainHighlightedActText: "minimalist", mainTrailingActText: "social media.", subActText: "Tired of the rat race on insta, snap, tik-tok, \"meta\"?", bottomActArea: AnyView(
                    VStack(alignment: .center) {
                        Button {
                            print("going to the sign in page")
                            
                            self.navigationStack.push(PhoneVerificationView())
                        } label: {
                            Text("Start Your Detox")
                                .fontWeight(.heavy)
                                .foregroundColor(NirvanaColor.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(NirvanaColor.teal)
                                .clipShape(Capsule())
                                .shadow(radius:10)
                        }
                       
                            
                        Link("Learn More", destination: URL(string: NirvanaConstants.landingPageUrl)!)
                            .font(.caption)
                            .foregroundColor(NirvanaColor.teal)
                        
                        //learn more button to usenirvana.com
                    }
                        .padding(.top, 20)
                    )
        )
    } // View body
} // View


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView().environmentObject(AuthSessionStore())
    }
}


struct LearnMoreView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            
            Text("🍃your minimalist social media\n")
                .font(.title)
                .foregroundColor(NirvanaColor.black)
            Text("tired of the rat race on ")
                .font(.title)
            Text("insta, tiktok, snap, \"meta\"...?\n")
                .font(.title)
                .foregroundColor(NirvanaColor.light)
            Text("start your detox with us and:\n- live in the present\n- build a more intimate inner circle\n- cut out the noise\n- focus on your goals and personal growth")
                .font(.title)
            Text("p.s. we don't sell your data or hire phd's to drug you...")
                .font(.subheadline)
            
            Spacer()
            
            Button("Dismiss Me") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }.padding(25)
    }
}
