//
//  SettingsDetailViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

class SettingsDetailViewModel {
    private let router: SettingsDetailRouter
    private let dataController: SettingsDetailDataController

    private var currentPresentation: SettingsDetailPresentation = .init(sections: [])

    enum Change {
        case title(title: String)
        case presentation(presentation: SettingsDetailPresentation)
    }

    var changeHandler: ((Change) -> Void)?

    init(dataController: SettingsDetailDataController, router: SettingsDetailRouter) {
        self.dataController = dataController
        self.router = router 
    }

    func initialize() {
        let currentItem = dataController.getItem()
        handleSettingsItem(currentItem)
    }

    var osTheme: UIUserInterfaceStyle {
        return UIScreen.main.traitCollection.userInterfaceStyle
    }
}

// MARK: - Handle Settings Item
extension SettingsDetailViewModel {
    private func handleSettingsItem(_ item: SettingsItem) {
        switch item {
        case .theme:
           createThemePresentation()
        case .textSize:
           createTextSizePresentation()
        }
    }
}

// MARK: - Theme
extension SettingsDetailViewModel {
    private func createThemePresentation() {
        
    }
}

// MARK: - Text Size
extension SettingsDetailViewModel {
    private func createTextSizePresentation() {

    }
}


// MARK: - Trigger Change
extension SettingsDetailViewModel {
    private func trigger(_ change: Change) {
        guard let handler = changeHandler else { return }
        DispatchQueue.main.async {
            handler(change)
        }
    }
}
