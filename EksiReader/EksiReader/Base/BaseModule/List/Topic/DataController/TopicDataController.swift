//
//  TodayDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TopicDataController: PagableDataController {

    private let topicId: Int
    private var storage: ERStorage?

    var currentStorage: ERStorage {
        return storage ?? APP.storage
    }

    typealias T = TopicEntry
    typealias Response = TodayTopicResponse

    var entries: [TopicEntry] = []
    var currentPage: Int = 0
    var totalPageCount: Int = .max
    var response: TodayTopicResponse?

    var endpoint: EREndpoint? {
        return EREndpoint.topic(id: topicId, page: currentPage)
    }

    // Use  storage  as dependency when testing
    init(topicId: Int, storage: ERStorage? = nil) {
        self.topicId = topicId
        self.storage = storage
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
