//
//  colors.swift
//  nirvana-ios
//
//  Created by Arjun Patel on 12/11/21.
//

import Foundation
import SwiftUI

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

final class NirvanaColors {
    static let teal:Color = Color(red: 0.0, green: 0.314, blue: 0.314)
    static let bgLightGrey:Color = Color(red: 0.898, green: 0.898, blue: 0.898)
    static let white: Color = Color.white
}
