//
//  TopicEntryPresentation.swift
//  EksiReader
//
//  Created by aybek can kaya on 13.04.2022.
//

import Foundation
import UIKit

struct TopicEntryPresentation: DeclarativeListItem, PagablePresentation {
    typealias PresentationEntry = TodayTopicEntry

    let id: Int
    let authorName: String
    let authorImageURL: String?
    let content: String
    let favoriteCount: Int
    let commentCount: Int
    let createdDatePresentable: String
    let createdDateValue: Date?

    private(set) var isFavorited: Bool = false

    init(entry: TodayTopicEntry) {
        self.id = entry.id
        self.authorName = entry.author?.nick ?? ""
        self.authorImageURL = entry.avatarUrl
        self.content = entry.content
        self.favoriteCount = entry.favoriteCount
        self.commentCount = entry.commentCount
        self.createdDateValue = entry.created.toDate(with: DateFormatter.erStringToDateFormatter)
        self.createdDatePresentable = self.createdDateValue?.toString(with: DateFormatter.erDateToStringFormatter) ?? ""
    }

    mutating func setFavorited(_ isFavorite: Bool) {
        self.isFavorited = isFavorite
    }
}
