//
//  SearchPresenter.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation
import UIKit

struct SettingsItemPresentation: DeclarativeListItem {
    let itemId: Int
    let icon: String
    let title: String
    let description: String

    init(settingsItem: SettingsItem) {
        itemId = settingsItem.rawValue
        icon = settingsItem.icon
        title = settingsItem.title
        description = settingsItem.settingsDescription
    }
}

struct SettingsPresentation {
    let items: [SettingsItemPresentation]

    init(settingsItems: [SettingsItem]) {
        self.items = settingsItems.compactMap {.init(settingsItem: $0)}
    }
}
