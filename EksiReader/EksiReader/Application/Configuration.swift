//
//  Configuration.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

struct C {

}

// MARK: - Color
extension C {
    struct Color {
        static let black: UIColor = .init(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
}

// MARK: - Font 
extension C {
    enum Font: String {
        case regular = "Verdana"
        case bold = "Verdana-Bold"
        case italic = "Verdana-Italic"
        case boldItalic = "Verdana-BoldItalic"

        func font(size: CGFloat) -> UIFont {
            return UIFont(name: self.rawValue, size: size)!
        }
    }
}

// MARK: - UIColor + Hex
extension UIColor {
    public convenience init(hex: String) {
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
        self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
}
