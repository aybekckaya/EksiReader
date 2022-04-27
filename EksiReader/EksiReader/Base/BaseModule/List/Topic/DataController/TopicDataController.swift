//
//  TodayDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TopicDataController: PagableDataController {

    typealias T = TopicEntry
    typealias Response = TodayTopicResponse

    private let topicId: Int
    private var storage: ERStorage?
    private var _sortingType: ERListSortType = .lastToFirst

    var entries: [TopicEntry] = []
    var currentPageIndex: Int = 0
    var finalPageIndex: Int = Int.max
    var totalPages: Int = 0
    var response: TodayTopicResponse?

    var endpoint: EREndpoint? { EREndpoint.topic(id: topicId, page: currentPageIndex) }
    var currentStorage: ERStorage { storage ?? APP.storage }
    var sortingType: ERListSortType { _sortingType }

    // Use  storage  as dependency when testing
    init(topicId: Int, storage: ERStorage? = nil) {
        self.topicId = topicId
        self.storage = storage
        switch self.sortingType {
        case .firstToLast:
            self.currentPageIndex = 0
            self.finalPageIndex = Int.max
        case .lastToFirst:
            self.currentPageIndex = Int.max
            self.finalPageIndex = 0
        }
    }

    deinit {
        NSLog("DEINIT Topic Data Controller")
    }
}

// MARK: - Public
extension TopicDataController {
    func isTopicFollowing() -> Bool {
        return currentStorage.isEntryFollowing(entryId: topicId)
    }

    func toggleTopicFollowStatus() {
        currentStorage.toggleTopicFollowingStatus(of: topicId)
        NSLog("Toggling: \(topicId), Following Topics: \(currentStorage.localStorageModel.followingEntries)")
        let notificationModel = TopicFollowStatusNotificationModel(topicId: topicId,
                                                                   isFollowing: isTopicFollowing())
        NotificationCenter.default.post(name: ERKey.NotificationName.reloadTopicList, object: notificationModel)
    }

    func getEntry(by id: Int) -> TopicEntry {
        return entries
            .first { $0.id == id }!
    }

    func toggleSortingType() {
        if _sortingType == .lastToFirst {
            _sortingType = .firstToLast
        } else {
            _sortingType = .lastToFirst
        }
    }

    func isEntryFavorited(entryId: Int) -> Bool {
        return currentStorage.localStorageModel.favoritedEntries.contains(entryId)
    }

    func isAuthorBlocked(authorId: Int) -> Bool {
        return currentStorage.localStorageModel.blockedAuthors.contains(authorId)
    }

    func changeFavoriteStatusOfEntry(entryId: Int) {
        currentStorage.toggleFavoriteStatus(of: entryId)
    }
}
