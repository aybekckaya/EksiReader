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

    var entries: [TopicEntry] = []
    var currentPageIndex: Int = 0
    var finalPageIndex: Int = Int.max
    var response: TodayTopicResponse?

    var endpoint: EREndpoint? {
        return EREndpoint.topic(id: topicId, page: currentPageIndex)
    }

    var currentStorage: ERStorage {
        return storage ?? APP.storage
    }

    var sortingType: ERListSortType {
        return .lastToFirst
    }


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
}

// MARK: - Public
extension TopicDataController {
    func isEntryFavorited(entryId: Int) -> Bool {
        return currentStorage.localStorageModel.favoritedEntries.contains(entryId)
    }

    func changeFavoriteStatusOfEntry(entryId: Int) {
        let currentFavoritedItems: [Int] = currentStorage.localStorageModel.favoritedEntries
        var newFavoritedItems: [Int] = []

        if isEntryFavorited(entryId: entryId) {
            newFavoritedItems = currentFavoritedItems
                .filter { $0 != entryId }
        } else {
            newFavoritedItems.append(entryId)
        }

        let newStorageModel: ERLocalModel = .init(favoritedEntries: newFavoritedItems,
                                                  favoritedAuthors: currentStorage.localStorageModel.favoritedAuthors)
        currentStorage.setLocalStorageModel(newStorageModel)
    }
}
