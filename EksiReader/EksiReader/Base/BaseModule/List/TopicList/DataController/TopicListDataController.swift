//
//  TodayDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

class TopicListDataController: PagableDataController {
    let pageTitle: String?

    typealias T = TopicListEntry
    typealias Response = TodaysResponse

    var entries: [TopicListEntry] = []
    var currentPage: Int = 0
    var totalPageCount: Int = Int.max
    var response: TodaysResponse?

    var endpoint: EREndpoint {
        EREndpoint.today(page: currentPage)
    }

    init(pageTitle: String?) {
        self.pageTitle = pageTitle
    }
}

// MARK: - Public
extension TopicListDataController {

}

