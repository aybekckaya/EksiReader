//
//  SettingsDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation

// Gets all datas from plists or other sources

class SettingsDetailDataController {
    private let itemId: Int

    init(itemId: Int) {
        self.itemId = itemId
    }

    func getItem() -> SettingsItem {
        let item = SettingsItem(rawValue: itemId)
        return item!
    }
}
