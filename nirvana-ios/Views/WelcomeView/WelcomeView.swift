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
        VStack(spacing: 0) {
            HeaderView()
            
            VStack {
                OnboardingImageView("undraw_friendship_mni7")
                
                OnboardingActionTextView(leadingText: "Your ", highlightedText: "minimalist ", trailingText: "social media", subActText: "tired of the rat race on insta, snap, tik-tok, \"meta\"?")
                
                OnboardingActionAreaView()
            }
            .padding()
            .frame(maxWidth: screenWidth - 20)

            Spacer()
        } //outermost vstack
        .accentColor(NirvanaColor.teal)
        .background(NirvanaColor.bgLightGrey)
        .navigationBarTitleDisplayMode(.inline)
    } // View body
} // View


struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}


struct OnboardingActionTextView: View {
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    private var mainLeadingActionText:String
    private var mainHighlightedActionText:String
    private var mainTrailingActionText:String
    
    private var subActionText:String
    
    init(leadingText:String, highlightedText: String, trailingText: String, subActText: String) {
        self.mainLeadingActionText = leadingText
        self.mainHighlightedActionText = highlightedText
        self.mainTrailingActionText = trailingText
        
        self.subActionText = subActText
    }
    
    var body : some View {
        VStack(alignment: .leading) {
            
            Text(self.mainLeadingActionText)
                .font(.title)
                .foregroundColor(NirvanaColor.black)
            + Text(self.mainHighlightedActionText)
                .font(.title)
                .foregroundColor(NirvanaColor.teal)
            + Text(self.mainTrailingActionText)
                .font(.title)
                .foregroundColor(NirvanaColor.black)
            
            Text(self.subActionText)
                .foregroundColor(Color.gray)
                .padding(.top, 5)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .frame(maxWidth: screenWidth - 20)
    }
}

struct OnboardingActionAreaView: View {
    var body : some View {
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
    }
}

struct OnboardingImageView: View {
    private var imageName:String
    
    init(_ imgName: String) {
        self.imageName = imgName
    }
    
    var body : some View {
        Image(self.imageName)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
