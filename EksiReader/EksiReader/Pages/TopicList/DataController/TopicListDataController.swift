//
//  TodayDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

class TopicListDataController: PagableDataController {
    var response: TodaysResponse?

    typealias T = TopicListEntry
    typealias Response = TodaysResponse

    var entries: [TopicListEntry] = []
    var currentPage: Int = 0
    var totalPageCount: Int = Int.max

    var endpoint: EREndpoint {
        EREndpoint.today(page: currentPage)
    }

   

    init() {

    }
}

// MARK: - Public
extension TopicListDataController {

}

