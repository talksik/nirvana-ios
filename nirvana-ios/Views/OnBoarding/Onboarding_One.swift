//
//  Onboarding-1.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/19/21.
//

import SwiftUI
import NavigationStack

struct Onboarding_One: View {
    @EnvironmentObject var navigationStack: NavigationStack
    
    @State var onboardingStepNumber = 0
    
    var body: some View {
        let stepViews = [
                    self.stepContent(imageName: "undraw_through_the_park_lxnl", leadingText: "Be", midText: "yourself", trailingText: "again", subText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present."),
                     self.stepContent(imageName: "undraw_through_the_park_lxnl", leadingText: "Be", midText: "yourself", trailingText: "again", subText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present."),
                     self.stepContent(imageName: "undraw_through_the_park_lxnl", leadingText: "Be", midText: "yourself", trailingText: "again", subText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present.")
        ]
        
        ZStack {
            // bg
            WavesGlassBackgroundView()
            
            // programmatic back button
            ZStack(alignment: .topLeading) {
                Color.clear
                
                Button {
                    self.navigationStack.pop()
                } label: {
                    Label("back", systemImage:"chevron.left")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                }
                .padding()
            }
            
            
            VStack(alignment: .center) {
                LogoHeaderView()
                
                TabView {
                    self.stepContent(imageName: "undraw_through_the_park_lxnl", leadingText: "Be", midText: "yourself", trailingText: "again", subText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present.")
                     self.stepContent(imageName: "undraw_through_the_park_lxnl", leadingText: "Be", midText: "yourself", trailingText: "again", subText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present.")
                     self.stepContent(imageName: "undraw_through_the_park_lxnl", leadingText: "Be", midText: "yourself", trailingText: "again", subText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present.")
                }
                            
                Spacer()
                
                // bottom controls
                HStack {
                    Button {
                        self.navigationStack.push(AddBasicInfoView())
                    } label: {
                        Text("Skip")
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Button {
                        self.onboardingStepNumber = (self.onboardingStepNumber + 1) % stepViews.count
                    } label: {
                        Label("Next", systemImage: "arrow.right")
                            .font(.title2)
                            .foregroundColor(NirvanaColor.teal)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 30)
            
//            OnboardingTemplateView(imgName: "undraw_through_the_park_lxnl", mainLeadingActText: "Be", mainHighlightedActText: "yourself", mainTrailingActText: "again.", subActText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present.")
        }
    }
    
    private func stepContent(imageName: String, leadingText: String, midText: String, trailingText: String, subText: String) -> some View {
        VStack {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading) {
                Text(leadingText + " ")
                    .font(.largeTitle)
                    .foregroundColor(NirvanaColor.black)
                    .fontWeight(.medium)
                + Text(midText + " ")
                    .font(.largeTitle)
                    .foregroundColor(NirvanaColor.teal)
                    .fontWeight(.medium)
                + Text(trailingText)
                    .font(.largeTitle)
                    .foregroundColor(NirvanaColor.black)
                    .fontWeight(.medium)
                    
                
                Text(subText)
                    .font(.headline)
                    .foregroundColor(Color.black.opacity(0.7))
                    .padding(.top, 5)
            }
        }
    }
}

struct Onboarding_One_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_One().environmentObject(AuthSessionStore())
    }
}
