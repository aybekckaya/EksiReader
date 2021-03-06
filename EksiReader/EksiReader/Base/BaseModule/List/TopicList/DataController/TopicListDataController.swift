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
    var currentPageIndex: Int = 0
    var finalPageIndex: Int = Int.max
    var totalPages: Int = 0
    var response: TodaysResponse?

    var endpoint: EREndpoint? {
        return getEndpoint()
    }

    var sortingType: ERListSortType {
        return .firstToLast
    }

    private var tabbarItem: EksiTabbarItem?

    init(tabbarItem: EksiTabbarItem? = nil) {
        self.tabbarItem = tabbarItem
        self.pageTitle = tabbarItem?.title 
    }

    func getEndpoint() -> EREndpoint? {
        guard let tabbarItem = self.tabbarItem else {
            return nil
        }

        switch tabbarItem {
        case .today:
            return .today(page: currentPageIndex)
        case .popular:
            let currentChannels = APP.channelManager.currentChannelFilter
            guard let jsonData = try? JSONEncoder().encode(currentChannels) else {
                return nil
            }
            return .popular(page: currentPageIndex, channelFilterData: jsonData)
        case .search, .settings, .notification:
            return nil
        }
    }
}

// MARK: - Public
extension TopicListDataController {

}

