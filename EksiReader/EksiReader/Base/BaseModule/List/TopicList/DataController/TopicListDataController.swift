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

    var endpoint: EREndpoint? {
        return getEndpoint()
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
            return .today(page: currentPage)
        case .popular:
            let currentChannels = APP.channelManager.currentChannelFilter
            guard let jsonData = try? JSONEncoder().encode(currentChannels) else {
                return nil
            }
            return .popular(page: currentPage, channelFilterData: jsonData)
        case .search:
            return nil
        case .settings:
            return nil
        }
    }
}

// MARK: - Public
extension TopicListDataController {

}

