//
//  Onboarding-1.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/19/21.
//

import SwiftUI

struct Onboarding_One: View {
    var body: some View {
        OnboardingTemplateView(imgName: "undraw_through_the_park_lxnl", mainLeadingActText: "Be", mainHighlightedActText: "yourself", mainTrailingActText: "again.", subActText: "No more endless feeds, media, fomo, anxiety...focus on you and be more present.")
    }
}

struct Onboarding_One_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_One()
    }
}
