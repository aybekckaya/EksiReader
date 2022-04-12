//
//  TodayRouter.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

final class TodayRouter {

    func routeToDetail(topicId: Int) {
        let dataController = TodayDetailDataController(topicId: topicId)
        let router = TodayDetailRouter()
        let viewModel = TodayDetailViewModel(dataController: dataController, router: router)
        let viewController = TodayDetailVC(viewModel: viewModel)
        ERNavUtility.push(viewController: viewController)
    }
}
