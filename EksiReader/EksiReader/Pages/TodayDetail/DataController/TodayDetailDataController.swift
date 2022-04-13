//
//  TodayDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TodayDetailDataController: PagableDataController {
    private let topicId: Int

    typealias T = TodayTopicEntry
    typealias Response = TodayTopicResponse

    var entries: [TodayTopicEntry] = []
    var currentPage: Int = 0
    var totalPageCount: Int = .max

    var endpoint: EREndpoint {
        return EREndpoint.topic(id: topicId, page: currentPage)
    }


    init(topicId: Int) {
        self.topicId = topicId
    }
}

// MARK: - Public
extension TodayDetailDataController {

}
