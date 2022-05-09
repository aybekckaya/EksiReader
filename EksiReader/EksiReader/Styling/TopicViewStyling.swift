//
//  TopicViewStyling.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit

// MARK: - Topic View
extension Styling {
    struct TopicCell {
        static var imageViewEdgeSize: CGFloat {
            return 50
        }

        static var dateLabelFont: UIFont {
            return C.Font.regular.font(size: 12)
        }

        static var dateLabelTextColor: UIColor {
            return APP.themeManager.getCurrentTheme().passiveTextColor
        }

        static var nickLabelFont: UIFont {
            return C.Font.italic.font(size: 12)
        }

        static var imageViewBGColor: UIColor {
            return .darkGray
        }


        static var nickLabelTextColor: UIColor {
            return APP.themeManager.getCurrentTheme().dominantTextColor
        }

        static var titleLineSpacing: CGFloat {
            return 8
        }

        static var verticalMargin: CGFloat {
            return 16
        }

        static var contentLabelFont: UIFont {
            return C.Font.regular.font(size: 14)
        }

        static var contentColor: UIColor {
            return APP.themeManager.getCurrentTheme().dominantTextColor
        }




    }
}

