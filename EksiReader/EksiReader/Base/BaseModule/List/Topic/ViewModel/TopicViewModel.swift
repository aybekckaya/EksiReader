//
//  TodayDetailViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import SwiftEntryKit

class TopicViewModel: PagableViewModel {
    typealias DataController = TopicDataController
    typealias Router = TopicRouter
    typealias Presentation = TopicItemPresentation
   // typealias Entry = DataController.T 

    var dataController: TopicDataController
    var router: TopicRouter
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<TopicItemPresentation>>?
    var currentPresentations: [TopicItemPresentation] = []

    var listSortingType: ERListSortType {
        dataController.sortingType
    }

    required init(dataController: TopicDataController, router: TopicRouter) {
        self.dataController = dataController
        self.router = router
        addListeners()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Listeners
extension TopicViewModel {
    private func addListeners() {
        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.changedSortingType, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.toggleSortingType()
        }

        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.changedEntryFollowStatus, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.toggleFollowStatus()
        }

        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.reloadTopicEntries, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            let newPresentations = self.updatedPresentations()
            self.changeHandler?(.presentations(itemPresentations: newPresentations))
        }
    }
}

// MARK: - Follow / Unfollow
extension TopicViewModel {
    private func toggleFollowStatus() {
        dataController.toggleTopicFollowStatus()
    }
}

// MARK: - Public
extension TopicViewModel {
    func navigateToFilterOptions() {
//        let viewController = TopicFilterViewController(soritngType: listSortingType,
//                                                       isFollowingEntry: dataController.isTopicFollowing())
//        var attributes = EKAttributes()
//        attributes.position = .bottom
//        SwiftEntryKit.display(entry: viewController, using: attributes, presentInsideKeyWindow: true)
        self.router.showMenuSheet(soritngType: listSortingType,
                                  isFollowingTopic: dataController.isTopicFollowing())
    }

    func navigateToAuthorInfo(authorId: Int) {
        guard authorId != -1 else { return }
        let authorNick = dataController.entries.first { $0.author?.id == authorId }?.author?.nick
        guard let authorNick = authorNick else { return }
        router.routeToAuthorInfo(authorNick: authorNick)
    }

    func navigateToReport(entryId: Int) {
        let entry = dataController.getEntry(by: entryId)
        guard let author = entry.author else { return }
        let authorModel = Author(id: author.id, nick: author.nick, avatarURL: entry.avatarUrl)
        router.showReportSheet(author: authorModel)
    }
    
    func toggleSortingType() {
        dataController.toggleSortingType()
        dataController.reset()
        self.resetEntries()
        self.loadNewItems()
    }

    func share(id: Int) {
        let link = "https://eksisozluk.com/entry/\(id)"
        router.showShareSheet(eksiLink: link)
    }

    func favorite(id: Int) {
        dataController.changeFavoriteStatusOfEntry(entryId: id)
        trigger(.presentations(itemPresentations: []))
        if dataController.isEntryFavorited(entryId: id) {
            trigger(.infoToast(message: "Favoriye aldığınız entry cihazınıza kaydedilmiştir. Kullanıcı adınız ile kayıt edilmesini istiyorsanız Ekşi Sözlük'ü ziyaret etmelisiniz"))
        }
    }

    func updatedPresentations() -> [TopicItemPresentation] {
        var newPresentations: [TopicItemPresentation] = []
        currentPresentations.forEach {
            var presentation = $0
            presentation.setFavorited(dataController.isEntryFavorited(entryId: $0.id))
            presentation.setAuthorBlocked(dataController.isAuthorBlocked(authorId: $0.authorId))
            newPresentations.append(presentation)
        }
        currentPresentations = newPresentations
        return newPresentations
    }
}







