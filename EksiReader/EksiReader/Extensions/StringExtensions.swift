//
//  StringExtensions.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation
import UIKit

extension String {
    func attributedTodayTitle() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Styling.TopicListCell.titleLineSpacing
        paragraphStyle.lineHeightMultiple = 1

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        return attributedString
    }

    func attributedTopicContent(links: [String]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Styling.TopicListCell.titleLineSpacing
        paragraphStyle.lineHeightMultiple = 1.2

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        let string = NSString(string: self)
        links.forEach { str in
            let range = string.range(of: str)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: range)
            attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.white, range: range)
        }

        return attributedString
    }
}
