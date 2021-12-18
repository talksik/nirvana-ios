//
//  OnboardingTrio.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import SwiftUI
import NavigationStack

struct OnboardingTrioView: View {
    @EnvironmentObject var navigationStack: NavigationStack
    
    var body: some View {
        TabView {
            OnboardingTemplateView(imgName: "undraw_through_the_park_lxnl", mainLeadingActText: "The path to living in the ", mainHighlightedActText: "present moment.", mainTrailingActText: "", subActText: "No more dopamine inducing  news feeds. No profiles so no anxiety about the past or what others think.")
            
            OnboardingTemplateView(imgName: "undraw_voice_assistant_nrv7", mainLeadingActText: "Talk with your authentic ", mainHighlightedActText: "voice.", mainTrailingActText: "", subActText: "Less screen time, no more endless text chats with meaningless junk. Start  mindfully listening.")
            
            OnboardingTemplateView(imgName: "undraw_connection_b-38-q", mainLeadingActText: "Be picky about your ", mainHighlightedActText: "inner circle.", mainTrailingActText: "", subActText: "You are who you hang out with. Maximum 8 people in your inner circle.", bottomActArea: AnyView(
                    VStack {
                        Button {
                            self.navigationStack.push(ContactsView())
                        } label: {
                            Text("Start Your Detox")
                                .bold()
                                .foregroundColor(NirvanaColor.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(NirvanaColor.teal)
                                .clipShape(Capsule())
                                .shadow(radius:10)
                        }                             
                    }.padding(.bottom, 20)
                )
            )
        }
        .navigationBarHidden(true)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
    }
}

struct OnboardingTrioView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTrioView().environmentObject(AuthSessionStore())
    }
}
