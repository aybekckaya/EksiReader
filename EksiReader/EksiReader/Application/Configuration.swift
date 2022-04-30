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


extension C {
    static let showLinksInTable: Bool = true
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

// MARK: - Theme
protocol ColorTheme {
    static var dominantTextColor: UIColor { get }
    static var passiveTextColor: UIColor { get }
    static var background: UIColor { get }
    static var barColor: UIColor { get }
    static var barTintColor: UIColor { get }
    static var tabbarUnSelected: UIColor { get }
    static var separatorColor: UIColor { get }
    static var neutralColor: UIColor { get }
    static var positiveColor: UIColor { get }
    static var negativeColor: UIColor { get }
}

struct DarkColorTheme: ColorTheme {
    static var neutralColor = UIColor(red: 0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var positiveColor = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    static var negativeColor = UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
    static var dominantTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var passiveTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7)
    static var background = UIColor(red: 21 / 255.0, green: 21 / 255.0, blue: 21 / 255.0, alpha: 1.0)
    static var barColor = UIColor(red: 16 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
    static var barTintColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var tabbarUnSelected = UIColor(red: 10 / 255.0, green: 10 / 255.0, blue: 10 / 255.0, alpha: 1.0)
    static var separatorColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2)
}

