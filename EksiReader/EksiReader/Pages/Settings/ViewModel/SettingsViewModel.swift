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
    case presentations(itemPresentations: [P])
    case error(error: EksiError)
}


class SettingsViewModel {
    private let dataController: SettingsDataController
    private let router: SettingsRouter

    init(dataController: SettingsDataController, router: SettingsRouter) {
        self.dataController = dataController
        self.router = router
    }
}
