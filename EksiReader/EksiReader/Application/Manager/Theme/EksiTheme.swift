//
//  EksiTheme.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

// MARK: - Theme
protocol ColorTheme {
    var identifier: String { get }
    var title: String { get }
    static var lightItemBackground: UIColor { get }
    static var dominantTextColor: UIColor { get }
    static var passiveTextColor: UIColor { get }
    var background: UIColor { get }
    static var barColor: UIColor { get }
    static var barTintColor: UIColor { get }
    static var tabbarUnSelected: UIColor { get }
    static var separatorColor: UIColor { get }
    static var neutralColor: UIColor { get }
    static var positiveColor: UIColor { get }
    static var negativeColor: UIColor { get }
}

struct DarkColorTheme: ColorTheme {
     var identifier: String { "Dark" }
     var title: String { "Koyu" }
    static var neutralColor = UIColor(red: 0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var positiveColor = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    static var negativeColor = UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
    static var dominantTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var passiveTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7)
    var background = UIColor(red: 21 / 255.0, green: 21 / 255.0, blue: 21 / 255.0, alpha: 1.0)
    static var barColor = UIColor(red: 16 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
    static var barTintColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var tabbarUnSelected = UIColor(red: 10 / 255.0, green: 10 / 255.0, blue: 10 / 255.0, alpha: 1.0)
    static var separatorColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2)
    static var lightItemBackground = UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 28 / 255.0, alpha: 1.0)
}

struct LightColorTheme: ColorTheme {
     var identifier: String { "Light" }
     var title: String { "Açık" }
    static var neutralColor = UIColor(red: 0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var positiveColor = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    static var negativeColor = UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
    static var dominantTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var passiveTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7)
    var background = UIColor(red: 210 / 255.0, green: 210 / 255.0, blue: 210 / 255.0, alpha: 1.0)
    static var barColor = UIColor(red: 16 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
    static var barTintColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    static var tabbarUnSelected = UIColor(red: 10 / 255.0, green: 10 / 255.0, blue: 10 / 255.0, alpha: 1.0)
    static var separatorColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2)
    static var lightItemBackground = UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 28 / 255.0, alpha: 1.0)
}


