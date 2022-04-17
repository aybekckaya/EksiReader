//
//  TodayDetailViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TodayDetailViewModel: PagableViewModel {
    typealias DataController = TodayDetailDataController
    typealias Router = TodayDetailRouter
    typealias Presentation = TopicEntryPresentation
    typealias Entry = TodayTopicEntry

    var dataController: TodayDetailDataController
    var router: TodayDetailRouter
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<TopicEntryPresentation>>?
    var currentPresentations: [TopicEntryPresentation] = []

    required init(dataController: TodayDetailDataController, router: TodayDetailRouter) {
        self.dataController = dataController
        self.router = router
    }
}

// MARK: - Public
extension TodayDetailViewModel {
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

    func updatedPresentations() -> [TopicEntryPresentation] {
        var newPresentations: [TopicEntryPresentation] = []
        currentPresentations.forEach {
            var presentation = $0
            presentation.setFavorited(dataController.isEntryFavorited(entryId: $0.id))
            newPresentations.append(presentation)
        }
        currentPresentations = newPresentations
        return newPresentations
    }

    func navigateToEntryViewController(entryId: Int) {
        self.router.routeToEntry(entryId: entryId)
    }
}





