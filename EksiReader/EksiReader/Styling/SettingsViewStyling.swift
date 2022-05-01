//
//  SettingsViewStyling.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

// MARK: - Settings View
extension Styling {
    struct SettingsView {
        struct Cell {
            static let titleFont = C.Font.bold.font(size: 14)
            static let descriptionFont = C.Font.regular.font(size: 12)

            static var titleColor: UIColor {
                return DarkColorTheme.dominantTextColor
            }

            static var descriptionColor: UIColor {
                return DarkColorTheme.passiveTextColor
            }

            static var iconColor: UIColor {
                return DarkColorTheme.passiveTextColor
            }

        }
    }
}

// MARK: - Settings Detail View
extension Styling {
    struct SettingsDetailView {
        static var containterViewBackgroundColor: UIColor {
            return DarkColorTheme.lightItemBackground
        }

        static var itemTitleFont: UIFont {
            return C.Font.regular.font(size: 13)
        }

        static var itemTitleColor: UIColor {
            return DarkColorTheme.dominantTextColor
        }

    }
}
