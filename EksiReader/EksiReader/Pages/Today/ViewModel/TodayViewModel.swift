//
//  TodayViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

class TodayViewModel: PagableViewModel {

    typealias DataController = TodayDataController
    typealias Router = TodayRouter
    typealias Presentation = TodayPresentation
    typealias Entry = TodaysEntry

    var dataController: TodayDataController
    var router: TodayRouter
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<TodayPresentation>>?
    var currentPresentations: [TodayPresentation] = []

    required init(dataController: DataController, router: Router) {
        self.dataController = dataController
        self.router = router
    }
}

// MARK: - Public
extension TodayViewModel {
    func selectItem(withIdentifier id: Int) {
        router.routeToDetail(topicId: id)
    }

}

// MARK: - Response Handler
extension TodayViewModel {

}


// MARK: - UI Manager
extension TodayViewModel {

}


