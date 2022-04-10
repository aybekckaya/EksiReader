//
//  TodayViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

class TodayViewModel {
    private let dataController: TodayDataController
    private let router: TodayRouter

    init(dataController: TodayDataController,
         router: TodayRouter) {
        self.dataController = dataController
        self.router = router
    }
}
