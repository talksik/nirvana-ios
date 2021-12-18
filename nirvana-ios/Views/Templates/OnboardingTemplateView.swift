//
//  OnboardingTemplateView.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/13/21.
//

import SwiftUI

struct OnboardingTemplateView: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    private var headerText: String?
    private var imageName:String?
    
    private var mainLeadingActionText:String?
    private var mainHighlightedActionText:String?
    private var mainTrailingActionText:String?
    
    private var subActionText:String?
    
    private var bottomActionArea:AnyView?
    
    init(hdrText:String? = nil,
         imgName:String? = nil,
         mainLeadingActText:String? = nil,
         mainHighlightedActText: String? = nil,
         mainTrailingActText:String? = nil,
         subActText: String? = nil,
         bottomActArea:AnyView? = nil) {
        self.headerText = hdrText
        self.imageName = imgName
        self.mainLeadingActionText = mainLeadingActText
        self.mainHighlightedActionText = mainHighlightedActText
        self.mainTrailingActionText = mainTrailingActText
        self.subActionText = subActText
        self.bottomActionArea = bottomActArea
    }
    
    var body: some View {        
        ZStack {
            // TODO: CAREFUL...this needs to be on top if any view is using this subview...otherwise elements will be dimmed and placed beneath this background
            WavesGlassBackgroundView()
            
            VStack(spacing: 0) {
                HeaderView()
                
                VStack {
                    self.onboardingHeaderText
                    
                    self.onboardingImageView
                    
                    self.onboardingActionTextView
                    
                    Spacer()
                    
                    self.bottomActionArea
                }
                .padding(.horizontal, screenWidth * 0.05)

                Spacer()
            } //outermost vstack
            .accentColor(NirvanaColor.teal)
            .navigationBarHidden(true)
        }
    }
    
    private var onboardingHeaderText: some View {
            ZStack {
                if (self.headerText != nil) {
                    Text(self.headerText!)
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundColor(NirvanaColor.teal)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
    
    private var onboardingImageView: some View {
        Image(self.imageName ?? "")
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    private var onboardingActionTextView: some View {
        ZStack {
            if (self.mainLeadingActionText == nil || self.mainHighlightedActionText == nil || self.mainTrailingActionText == nil || self.subActionText == nil) {
                EmptyView()
            } else {
                VStack(alignment: .leading) {
                    
                    Text(self.mainLeadingActionText! + " ")
                        .font(.title)
                        .foregroundColor(NirvanaColor.black)
                        .fontWeight(.medium)
                    + Text(self.mainHighlightedActionText! + " ")
                        .font(.title)
                        .foregroundColor(NirvanaColor.teal)
                        .fontWeight(.medium)
                    + Text(self.mainTrailingActionText!)
                        .font(.title)
                        .foregroundColor(NirvanaColor.black)
                        .fontWeight(.medium)
                    
                    Text(self.subActionText!)
                        .foregroundColor(Color.black.opacity(0.7))
                        .padding(.top, 5)
                    
                    Spacer()
                }
                .frame(maxWidth: screenWidth - 10)
            }
        }
    }
}

struct OnboardingTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTemplateView(hdrText: "let's get started", imgName: "undraw_friendship_mni7", mainLeadingActText: "Your", mainHighlightedActText: "minimalist", mainTrailingActText: "social media.", subActText: "Tired of the rat race on the test of th4e best oadf the best?", bottomActArea: AnyView(
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
        ).environmentObject(AuthSessionStore())
    }
}
