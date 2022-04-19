//
//  TodayPresentations.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation
import UIKit

struct TopicListItemPresentation: DeclarativeListItem, PagablePresentation {
    typealias PresentationEntry = TopicListEntry

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

