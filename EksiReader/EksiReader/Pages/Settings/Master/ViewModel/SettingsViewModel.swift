//
//  SearchViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation

typealias SettingsViewModelChangeCallback<T> = (T) -> Void

// MARK: - SearchViewModelChange
enum SettingsViewModelChange<P> {
    case title(title: String?)
    case loading(isVisible: Bool)
    case presentation(itemPresentation: P)
    case error(error: EksiError)
}


class SettingsViewModel {
    private let dataController: SettingsDataController
    private let router: SettingsRouter

    var changeHandler: SettingsViewModelChangeCallback<SettingsViewModelChange<SettingsPresentation>>?

    init(dataController: SettingsDataController, router: SettingsRouter) {
        self.dataController = dataController
        self.router = router
    }

    func initialize() {
        let items = dataController.getSettingsItems()
        let presentation: SettingsPresentation = .init(settingsItems: items)
        let title = "Ayarlar"
        changeHandler?(.title(title: title))
        changeHandler?(.presentation(itemPresentation: presentation))
    }

    func selectedItem(_ presentation: SettingsItemPresentation) {
        router.navigateToDetail(itemId: presentation.itemId)
    }
}
