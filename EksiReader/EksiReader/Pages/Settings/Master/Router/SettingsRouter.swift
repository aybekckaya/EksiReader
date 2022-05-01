//
//  SearchRouter.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation
import UIKit

class SettingsRouter {
    func navigateToDetail(itemId: Int) {
        let dataController = SettingsDetailDataController(itemId: itemId)
        let router = SettingsDetailRouter()
        let viewModel = SettingsDetailViewModel(dataController: dataController, router: router)
        let viewController = SettingDetailViewController(viewModel: viewModel)
        ERNavUtility.push(viewController: viewController)
    }
}
