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


//    private let dataController: TodayDetailDataController
//    private let router: TodayDetailRouter
//
//    init(dataController: TodayDetailDataController, router: TodayDetailRouter) {
//        self.dataController = dataController
//        self.router = router
//    }
}

// MARK: - Public
extension TodayDetailViewModel {

}





