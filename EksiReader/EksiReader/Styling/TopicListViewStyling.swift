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
            return Styling.Application.generalTextColor.withAlphaComponent(0.9)
        }

        static var countLabelColor: UIColor {
            return Styling.Application.generalTextColor.withAlphaComponent(0.7)
        }

        static var separatorColor: UIColor {
            let value: CGFloat = 255.0 / 255.0
            return UIColor(red: value, green: value, blue: value, alpha: 0.2)
        }
    }
}
