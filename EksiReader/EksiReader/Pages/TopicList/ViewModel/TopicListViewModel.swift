//
//  TodayViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

class TopicListViewModel: PagableViewModel {

    typealias DataController = TopicListDataController
    typealias Router = TopicListRouter
    typealias Presentation = TopicListItemPresentation
    typealias Entry = TopicListEntry

    var dataController: TopicListDataController
    var router: TopicListRouter
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<TopicListItemPresentation>>?
    var currentPresentations: [TopicListItemPresentation] = []

    required init(dataController: DataController, router: Router) {
        self.dataController = dataController
        self.router = router
    }
}

// MARK: - Public
extension TopicListViewModel {
    func selectItem(withIdentifier id: Int) {
        router.routeToDetail(topicId: id)
    }

    func initializeViewModel() {

    }

}

// MARK: - Response Handler
extension TopicListViewModel {

}


// MARK: - UI Manager
extension TopicListViewModel {

}


