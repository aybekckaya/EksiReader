//
//  TodayDetailViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation

class TodayDetailViewModel {
    private let dataController: TodayDetailDataController
    private let router: TodayDetailRouter

    init(dataController: TodayDetailDataController, router: TodayDetailRouter) {
        self.dataController = dataController
        self.router = router
    }
}

// MARK: - Public
extension TodayDetailViewModel {
    func loadNewItems() {
        
    }
}





