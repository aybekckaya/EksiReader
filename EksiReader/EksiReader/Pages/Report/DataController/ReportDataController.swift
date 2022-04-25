//
//  ReportDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation

class ReportDataController {
    private let author: Author
    private(set) var isAuthorBlocked: Bool = false

    init(author: Author) {
        self.author = author
    }

    func getAuthor() -> Author {
        isAuthorBlocked = APP.storage.localStorageModel.blockedAuthors.contains(author.id)
        return author
    }

    func toggleAuthorBlockState() {
        APP.storage.toggleAuthorBlockingStatus(of: author.id)
    }
}


