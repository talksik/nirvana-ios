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
        VStack(spacing: 0) {
            HeaderView()
            
            VStack {
                self.onboardingImageView
                
                self.onboardingActionTextView
                
                self.bottomActionArea
            }
            .padding()
            .frame(maxWidth: screenWidth - 20)

            Spacer()
        } //outermost vstack
        .accentColor(NirvanaColor.teal)
        .background(NirvanaColor.bgLightGrey)
        .navigationBarTitleDisplayMode(.inline)
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
                    
                    Text(self.mainLeadingActionText!)
                        .font(.title)
                        .foregroundColor(NirvanaColor.black)
                    + Text(self.mainHighlightedActionText!)
                        .font(.title)
                        .foregroundColor(NirvanaColor.teal)
                    + Text(self.mainTrailingActionText!)
                        .font(.title)
                        .foregroundColor(NirvanaColor.black)
                    
                    Text(self.subActionText!)
                        .foregroundColor(Color.gray)
                        .padding(.top, 5)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .frame(maxWidth: screenWidth - 20)
            }
        }
    }
}

struct OnboardingTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTemplateView()
    }
}
