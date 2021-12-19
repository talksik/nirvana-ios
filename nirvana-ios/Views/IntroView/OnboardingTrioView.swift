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
        VStack {
            TabView {
                OnboardingTemplateView(imgName: "undraw_through_the_park_lxnl", mainLeadingActText: "Stay present, stay ", mainHighlightedActText: "authentic.", mainTrailingActText: "", subActText: "No more consuming endless feeds and media, fomo, and anxiety.")
                
                OnboardingTemplateView(imgName: "undraw_connection_b-38-q", mainLeadingActText: "Be picky about your ", mainHighlightedActText: "inner circle.", mainTrailingActText: "", subActText: "You are who you hang out with. We limit your \"circle\" to 12 people.")
                
                OnboardingTemplateView(imgName: "undraw_voice_assistant_nrv7", mainLeadingActText: "A seamless way of communicating ", mainHighlightedActText: "voice.", mainTrailingActText: "", subActText: "Less screen time, no more endless text chats with meaningless junk. Start mindfully listening.", bottomActArea: AnyView(
                        VStack {
                            Button {
                                self.navigationStack.push(AddBasicInfoView())
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
                        }.padding(.bottom, 30)
                    )
                )
            }
            .navigationBarHidden(true)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }
}

struct OnboardingTrioView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTrioView().environmentObject(AuthSessionStore())
    }
}
