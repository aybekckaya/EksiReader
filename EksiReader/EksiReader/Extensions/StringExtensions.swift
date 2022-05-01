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
                                      value: paragraphStyle,
                                      range: NSMakeRange(0, attributedString.length))

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor,
                                      value: Styling.TopicCell.contentColor,
                                      range: NSMakeRange(0, attributedString.length))

        attributedString.addAttribute(NSAttributedString.Key.font,
                                      value: Styling.TopicCell.contentLabelFont,
                                      range: NSMakeRange(0, attributedString.length))

        return attributedString
    }
}

// MARK: - Line Height / Spacing
extension NSAttributedString {
    func lineHeight(_ height: CGFloat) -> NSAttributedString {
        let _self = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = height
        _self.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, _self.length))
        return NSAttributedString(attributedString: _self)
    }

    func lineSpacing(_ space: CGFloat) -> NSAttributedString {
        let _self = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space 
        _self.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, _self.length))
        return NSAttributedString(attributedString: _self)
    }
}
