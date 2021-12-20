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
        ZStack(alignment: .topLeading) {
            TabView {
                OnboardingTemplateView(imgName: "undraw_through_the_park_lxnl", mainLeadingActText: "Be", mainHighlightedActText: "yourself", mainTrailingActText: "again.", subActText: "No more endless feeds, profiles, media, fomo, anxiety...focus on you and be more present.")
                
                OnboardingTemplateView(imgName: "undraw_connection_b-38-q", mainLeadingActText: "Be picky about your", mainHighlightedActText: "inner circle.", mainTrailingActText: "", subActText: "You are who you hang out with. We kept things minimal because less is more...and we care.")
                
                OnboardingTemplateView(imgName: "undraw_voice_assistant_nrv7", mainLeadingActText: "Buttery smooth convos with your", mainHighlightedActText: "authentic voice.", mainTrailingActText: "", subActText: "Less screen time, no more meaningless texts. Start mindfully conversing without all of the noise.", bottomActArea: AnyView(
                        VStack {
                            Button {
                                self.navigationStack.push(AddBasicInfoView())
                            } label: {
                                Text("Get Started")
                                    .bold()
                                    .foregroundColor(NirvanaColor.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
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
            .ignoresSafeArea(.all)
            
            
            HStack(alignment: .center) {
                Button {
                    self.navigationStack.pop()
                } label: {
                    Label("back", systemImage:"chevron.left")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
                
                Spacer()
                
                Button {
                    self.navigationStack.push(AddBasicInfoView())
                } label: {
                    Text("Skip")
                        .foregroundColor(NirvanaColor.dimTeal)
                }
            }
            .padding()
        }
        
    }
}

struct OnboardingTrioView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTrioView().environmentObject(AuthSessionStore())
    }
}
