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
    var lightItemBackground: UIColor { get }
    var dominantTextColor: UIColor { get }
    var passiveTextColor: UIColor { get }
    var background: UIColor { get }
    var barColor: UIColor { get }
    var barTintColor: UIColor { get }
    var tabbarUnSelected: UIColor { get }
    var separatorColor: UIColor { get }
    var neutralColor: UIColor { get }
    var positiveColor: UIColor { get }
    var negativeColor: UIColor { get }
}

struct DarkColorTheme: ColorTheme {
     var identifier: String { "Dark" }
     var title: String { "Koyu" }
    var neutralColor = UIColor(red: 0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    var positiveColor = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    var negativeColor = UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
    var dominantTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
     var passiveTextColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.7)
    var background = UIColor(red: 21 / 255.0, green: 21 / 255.0, blue: 21 / 255.0, alpha: 1.0)
     var barColor = UIColor(red: 16 / 255.0, green: 16 / 255.0, blue: 16 / 255.0, alpha: 1.0)
     var barTintColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
     var tabbarUnSelected = UIColor(red: 10 / 255.0, green: 10 / 255.0, blue: 10 / 255.0, alpha: 1.0)
     var separatorColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.2)
     var lightItemBackground = UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 28 / 255.0, alpha: 1.0)
}

struct LightColorTheme: ColorTheme {
     var identifier: String { "Light" }
     var title: String { "Açık" }
     var neutralColor = UIColor(red: 0 / 255.0, green: 122.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
     var positiveColor = UIColor(red: 76.0 / 255.0, green: 217.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    var negativeColor = UIColor(red: 255.0 / 255.0, green: 59.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
     var dominantTextColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0)
     var passiveTextColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.7)
    var background = UIColor(red: 250 / 255.0, green: 250 / 255.0, blue: 250 / 255.0, alpha: 1.0)
     var barColor = UIColor(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0)
     var barTintColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1.0)
     var tabbarUnSelected = UIColor(red: 100 / 255.0, green: 100 / 255.0, blue: 100 / 255.0, alpha: 1.0)
     var separatorColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 0.2)
     var lightItemBackground = UIColor(red: 228 / 255.0, green: 228 / 255.0, blue: 228 / 255.0, alpha: 1.0)
}


