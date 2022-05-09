//
//  TodaysView.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit

// MARK: - Topic List View
extension Styling {
    struct TopicListView {

    }

    struct TopicListCell {
        static var titleLineSpacing: CGFloat {
            return 8
        }

        static var verticalMargin: CGFloat {
            return 16
        }

        static var titleFont: UIFont {
            return C.Font.regular.font(size: 14)
        }

        static var countLabelFont: UIFont {
            return C.Font.regular.font(size: 12)
        }

        static var titleColor: UIColor {
            return APP.themeManager.getCurrentTheme().dominantTextColor
        }

        static var countLabelColor: UIColor {
            return APP.themeManager.getCurrentTheme().passiveTextColor
        }

        static var followSignColor: UIColor {
            return APP.themeManager.getCurrentTheme().neutralColor
        }

        static var separatorColor: UIColor {
            return APP.themeManager.getCurrentTheme().separatorColor
        }
    }
}
