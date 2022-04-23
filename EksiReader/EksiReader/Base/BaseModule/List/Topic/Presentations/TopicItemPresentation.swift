//
//  TopicEntryPresentation.swift
//  EksiReader
//
//  Created by aybek can kaya on 13.04.2022.
//

import Foundation
import UIKit

struct TopicItemPresentation: DeclarativeListItem, PagablePresentation, DateablePresentation {
    typealias PresentationEntry = TopicEntry

    let id: Int
    let authorName: String
    let authorImageURL: String?
    let content: NSAttributedString
    let favoriteCount: Int
    let commentCount: Int
    let createdDatePresentable: String
    let _createdDateValue: Date?
    let attachmentURLs: [String]

    var createdDateValue: Date? {
        _createdDateValue
    }

    private(set) var isFavorited: Bool = false

    init(entry: TopicEntry) {
        self.id = entry.id
        self.authorName = entry.author?.nick ?? ""
        self.authorImageURL = entry.avatarUrl
        self.favoriteCount = entry.favoriteCount
        self.commentCount = entry.commentCount
        self.attachmentURLs = entry.content.getLinks()
        self.content = entry.content.attributedTopicContent(links: self.attachmentURLs)
        self._createdDateValue = entry.created.toDate(with: DateFormatter.erStringToDateFormatter)
        self.createdDatePresentable = self._createdDateValue?.toString(with: DateFormatter.erDateToStringFormatter) ?? ""
    }

    mutating func setFavorited(_ isFavorite: Bool) {
        self.isFavorited = isFavorite
    }
}

