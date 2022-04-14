//
//  TodayPresentations.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation
import UIKit

struct TodayPresentation: DeclarativeListItem, PagablePresentation {
    typealias PresentationEntry = TodaysEntry

    let id: Int
    let title: String
    let count: Int
    let attributedTitle: NSAttributedString

init(entry: PresentationEntry) {
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
        paragraphStyle.lineHeightMultiple = 1

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        return attributedString
    }
}
