//
//  TodayDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TodayDetailDataController {
    private let topicId: Int

    private var currentPage: Int = 1
    private var maxPage: Int = Int.max

    init(topicId: Int) {
        self.topicId = topicId
    }
}

// MARK: - Public
extension TodayDetailDataController {
    func loadNewItems() {
        EksiCloud.shared
            .call(endpoint: .topic(id: topicId, page: currentPage), responseType: TodayTopicResponse.self) { response in
                NSLog("Res: \(response)")
        }
    }
}
