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
            return Styling.Application.navigationBarColor
        }

        static var textColor: UIColor {
            let value: CGFloat = 255.0 / 255.0
            return UIColor(red: value, green: value, blue: value, alpha: 1.0)
        }

        static var titleFont: UIFont {
            return C.Font.regular.font(size: 12)
        }

    }
}
