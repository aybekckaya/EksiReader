//
//  CustomViewStyling.swift
//  EksiReader
//
//  Created by aybek can kaya on 23.04.2022.
//

import Foundation
import UIKit

// MARK: - PagingView
extension Styling {
    struct PagingView {
        static var backgroundColor: UIColor {
            return APP.themeManager.getCurrentTheme().barColor
        }

        static var textColor: UIColor {
            return APP.themeManager.getCurrentTheme().dominantTextColor
        }

        static var titleFont: UIFont {
            return C.Font.regular.font(size: 12)
        }
    }
}

extension Styling {
    struct ReportView {
        static var nickFont: UIFont {
            return C.Font.italic.font(size: 15)
        }
    }
}
