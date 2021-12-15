//
//  colors.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

final class NirvanaColor {
    static let teal:Color = Color(red: 0.0, green: 0.314, blue: 0.314)
    static let bgLightGrey:Color = Color(red: 0.898, green: 0.898, blue: 0.898)
    static let white: Color = Color.white
    static let black: Color = Color.black
    
    // turqouise and stones color palettes
    static let light:Color = Color(hex: "2a416a")
    static let orangy:Color = Color(hex: "305955")
    static let solidTeal:Color = Color(hex: "258786")
    static let dimTeal:Color = Color(hex: "ca7558")
    static let solidBlue:Color = Color(hex: "9ec2b6")
}
