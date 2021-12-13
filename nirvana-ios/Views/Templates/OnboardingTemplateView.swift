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
    
    private let headerText: String?
    private let imageName:String?
    
    private let mainLeadingActionText:String?
    private let mainHighlightedActionText:String?
    private let mainTrailingActionText:String?
    
    private let subActionText:String?
    
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
            // nav bar
            HeaderView()
            
            VStack {
                // imported image name
                
                
                if (self.mainLeadingActionText != nil) { //only show section if leading text there assuming everything is won't be there
                    
                }
                
                // passed in action area from template user
                self.bottomActionArea
                
            }
            .padding()
            .frame(maxWidth: screenWidth - 20)

            Spacer()
        } // Vstack
        .accentColor(NirvanaColor.teal)
        .background(NirvanaColor.bgLightGrey)
        .navigationBarTitleDisplayMode(.inline)
        //        .background(RadialGradient(gradient: Gradient(colors: [NirvanaColor.teal.opacity(0.1), NirvanaColor.bgLightGrey, NirvanaColor.bgLightGrey]), center: .center, startRadius: 0, endRadius: 200)
        //        )
    }
}

struct OnboardingTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTemplateView()
    }
}
