//
//  TodayDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

typealias TopicDataControllerCallback = ([TodayTopicEntry], [TodayTopicEntry], EksiError?) -> Void

class TodayDetailDataController {
    private let topicId: Int

    private var entries: [TodayTopicEntry] = []
    private var currentPage: Int = 1
    private var totalPageCount: Int = Int.max

    init(topicId: Int) {
        self.topicId = topicId
    }
}

// MARK: - Public
extension TodayDetailDataController {
    func resetEntries() {
        self.entries = []
        self.currentPage = 1
        self.totalPageCount = Int.max
    }

    func canLoadNewItems() -> Bool {
        return currentPage < totalPageCount
    }

    func loadNewItems(_ callback: @escaping TopicDataControllerCallback) {
        guard canLoadNewItems() else {
            callback(entries, [], nil)
            return
        }

        let currentEntries = self.entries
        EksiCloud.shared
            .call(endpoint: .topic(id: topicId, page: currentPage), responseType: TodayTopicResponse.self) {[weak self] response in
                guard let self = self else {
                    callback(currentEntries, [], .selfIsDeallocated)
                    return
                }
                self.handleResponse(response, callback: callback)
        }
    }
}

// MARK: - Handle Response
extension TodayDetailDataController {
    private func handleResponse(_ response: TodayTopicResponse?, callback: @escaping TopicDataControllerCallback) {
        //NSLog("Res: \(response)")
        guard let response = response else {
            callback(entries, [], .todaysResponseIsNil)
            return
        }

        if let message = response.message {
            NSLog("Show Error !!!")
        }

        self.currentPage = response.pageIndex
        self.totalPageCount = response.pageCount
        let newEntries = response.entries
        entries.append(contentsOf: newEntries)
        callback(entries, newEntries, nil)

    }
}
