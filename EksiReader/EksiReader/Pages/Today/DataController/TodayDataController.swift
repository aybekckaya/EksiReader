//
//  TodayDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

// current_entries, new_entries, error
typealias TodayDataControllerCallback = ([TodaysEntry], [TodaysEntry], EksiError?) -> Void

class TodayDataController {
    private var entries: [TodaysEntry] = []
    private var currentPage: Int = 1
    private var totalPageCount: Int = Int.max

    init() {

    }
}

// MARK: - Public
extension TodayDataController {
    func resetEntries() {
        self.entries = []
        self.currentPage = 1
        self.totalPageCount = Int.max
    }

    func canLoadNewItems() -> Bool {
        return currentPage < totalPageCount
    }

    func loadNewItems(_ callback: @escaping TodayDataControllerCallback) {
        guard canLoadNewItems() else {
            callback(entries, [], nil)
            return
        }
        let currentEntries = self.entries
        EksiCloud.shared
            .call(endpoint: .today(page: currentPage), responseType: TodaysResponse.self) { [weak self] response in
                guard let self = self else {
                    callback(currentEntries, [], .selfIsDeallocated)
                    return
                }
                self.handleResponse(response, callback: callback)
        }
    }
}

// MARK: - Response Handler
extension TodayDataController {
    private func handleResponse(_ response: TodaysResponse?, callback: @escaping TodayDataControllerCallback) {
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


