//
//  NotificationViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 25.04.2022.
//

import Foundation

class NotificationViewModel {
    private let dataController: NotificationDataController
    private let router: NotificationRouter

    init(dataController: NotificationDataController, router: NotificationRouter) {
        self.dataController = dataController
        self.router = router
    }
}
