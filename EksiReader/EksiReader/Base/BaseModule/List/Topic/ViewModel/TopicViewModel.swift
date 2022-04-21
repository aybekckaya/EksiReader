//
//  TodayDetailViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TopicViewModel: PagableViewModel {
    typealias DataController = TopicDataController
    typealias Router = TopicRouter
    typealias Presentation = TopicItemPresentation
   // typealias Entry = DataController.T 

    var dataController: TopicDataController
    var router: TopicRouter
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<TopicItemPresentation>>?
    var currentPresentations: [TopicItemPresentation] = []

    required init(dataController: TopicDataController, router: TopicRouter) {
        self.dataController = dataController
        self.router = router
    }
}

// MARK: - Public
extension TopicViewModel {
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
            newPresentations.append(presentation)
        }
        currentPresentations = newPresentations
        return newPresentations
    }

    func navigateToEntryViewController(entryId: Int) {
        self.router.routeToEntry(entryId: entryId)
    }
}




