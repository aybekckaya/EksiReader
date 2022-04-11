//
//  TodayPresentations.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation
import UIKit

struct TodayPresentation: DeclarativeListItem {
    let id: Int
    let title: String
    let count: Int
    let attributedTitle: NSAttributedString
}

extension TodayPresentation {
    init(entry: TodaysEntry) {
        self.id = entry.id
        self.title = entry.title
        self.count = entry.fullCount
        self.attributedTitle = entry.title.attributedTodayTitle()
    }
}

extension String {
    func attributedTodayTitle() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Styling.TodaysCell.titleLineSpacing

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        return attributedString
    }
}
