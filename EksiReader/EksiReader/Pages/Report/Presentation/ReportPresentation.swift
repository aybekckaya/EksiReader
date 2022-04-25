//
//  ReportPresentation.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation

struct ReportPresentation {
    let authorId: Int
    let authorNick: String
    let authorAvatarURL: String?
    let isBlocked: Bool

    init(author: Author, isBlocked: Bool ) {
        self.authorId = author.id
        self.authorNick = author.nick
        self.authorAvatarURL = author.avatarURL
        self.isBlocked = isBlocked
    }
}
