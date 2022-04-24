//
//  TodayPresentations.swift
//  EksiReader
//
//  Created by aybek can kaya on 11.04.2022.
//

import Foundation
import UIKit

struct TopicListItemPresentation: PagableListItem, PagablePresentation {
    typealias PresentationEntry = TopicListEntry

    let id: Int
    let title: String
    let count: Int
    let attributedTitle: NSAttributedString
    let entryPage: Int

    var page: Int { entryPage }

    init(entry: PresentationEntry, entryPage: Int) {
        self.id = entry.id
        self.entryPage = entryPage
        self.title = entry.title
        self.count = entry.fullCount
        self.attributedTitle = entry.title.attributedTodayTitle()
    }
}
