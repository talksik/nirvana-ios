//
//  OnboardingTrio.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/14/21.
//

import SwiftUI
import NavigationStack

struct OnboardingOneView: View {
    @EnvironmentObject var navigationStack: NavigationStack
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        OnboardingTemplateView(imgName: "undraw_explore_re_8l4v-1", mainLeadingActText: "Be", mainHighlightedActText: "yourself", mainTrailingActText: "again.", subActText: "No more endless feeds, profiles, media, fomo, anxiety...focus on you and be more present.", bottomActArea: AnyView(
            VStack {
                // little bar to show progress out of three steps
                HStack {
                    Capsule()
                        .frame(width: 20, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                    Capsule()
                        .frame(width: 5, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                    Capsule()
                        .frame(width: 5, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                }
                .padding()
                
                HStack {
                    Button {
                        self.navigationStack.push(OnboardingTwo())
                    } label: {
                        Text("Next")
                            .fontWeight(.heavy)
                            .foregroundColor(NirvanaColor.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                    
                    // skip to hub
                    Button {
                        self.navigationStack.push(InnerCircleView())
                    } label: {
                        Text("Skip")
                            .font(.caption)
                            .foregroundColor(NirvanaColor.teal)
                    }
                }
            }
        ))
    }
}

struct OnboardingTrioView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingOneView().environmentObject(AuthSessionStore())
    }
}

struct OnboardingTwo: View {
    @EnvironmentObject var navigationStack: NavigationStack
    var body: some View {
        OnboardingTemplateView(imgName: "undraw_connection_b-38-q", mainLeadingActText: "Be picky about your", mainHighlightedActText: "inner circle.", mainTrailingActText: "", subActText: "You are who you hang out with. We kept things minimal because less is more...and we care.", bottomActArea: AnyView(
            VStack {
                // little bar to show progress out of three steps
                HStack {
                    Capsule()
                        .frame(width: 5, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                    Capsule()
                        .frame(width: 20, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                    Capsule()
                        .frame(width: 5, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                }
                .padding()
                
                HStack {
                    Button {
                        self.navigationStack.pop()
                    } label: {
                        Label("back", systemImage:"chevron.left")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .foregroundColor(NirvanaColor.teal)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                    
                    Button {
                        self.navigationStack.push(OnboardingThree())
                    } label: {
                        Text("Next")
                            .fontWeight(.heavy)
                            .foregroundColor(NirvanaColor.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                    
                    // skip to hub
                    Button {
                        self.navigationStack.push(InnerCircleView())
                    } label: {
                        Text("Skip")
                            .font(.caption)
                            .foregroundColor(NirvanaColor.teal)
                    }
                }
            }
        ))
    }
}


struct OnboardingThree: View {
    @EnvironmentObject var navigationStack: NavigationStack
    var body: some View {
        OnboardingTemplateView(imgName: "undraw_voice_assistant_nrv7", mainLeadingActText: "Buttery smooth convos with your", mainHighlightedActText: "authentic voice.", mainTrailingActText: "", subActText: "Less screen time, no more meaningless texts. Start mindfully conversing without all of the noise.", bottomActArea: AnyView(
            VStack {
                // little bar to show progress out of three steps
                HStack {
                    Capsule()
                        .frame(width: 5, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                    Capsule()
                        .frame(width: 5, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                    Capsule()
                        .frame(width: 20, height: 5)
                        .foregroundColor(NirvanaColor.teal)
                    
                }
                .padding()
                
                HStack {
                    Button {
                        self.navigationStack.pop()
                    } label: {
                        Label("back", systemImage:"chevron.left")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                            .foregroundColor(NirvanaColor.teal)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                    
                    Button {
                        self.navigationStack.push(InnerCircleView())
                    } label: {
                        Text("Get Started")
                            .fontWeight(.heavy)
                            .foregroundColor(NirvanaColor.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(NirvanaColor.teal)
                            .clipShape(Capsule())
                            .shadow(radius:10)
                    }
                }
            }
        ))
    }
}
