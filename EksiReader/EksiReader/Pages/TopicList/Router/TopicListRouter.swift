//
//  TodayRouter.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

final class TopicListRouter {

    func routeToDetail(topicId: Int) {
        let dataController = TopicDataController(topicId: topicId)
        let router = TopicRouter()
        let viewModel = TopicViewModel(dataController: dataController, router: router)
        let viewController = TopicViewController(viewModel: viewModel)
        ERNavUtility.push(viewController: viewController)
    }
}
