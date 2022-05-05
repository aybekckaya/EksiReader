//
//  SettingsDetailDataController.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation

class SettingsDetailDataController {
    private let itemId: Int
    
    let colorTheme = Theme()

    init(itemId: Int) {
        self.itemId = itemId
    }

    func getItem() -> SettingsItem {
        let item = SettingsItem(rawValue: itemId)
        return item!
    }
    
    struct Theme {
        func shouldUseDeviceValues(_ value: Bool) {
            APP.themeManager.setIsUsingDeviceValues(value)
            NotificationCenter.default.post(name: ERKey.NotificationName.colorThemeChanged, object: nil)
        }
        
        func setColorTheme(_ value: ColorTheme) {
            let currentTheme = getCurrentTheme()
            APP.themeManager.setCurrentTheme(value)
            if currentTheme.identifier != value.identifier {
                NotificationCenter.default.post(name: ERKey.NotificationName.colorThemeChanged, object: nil)
            }
            
        }
        
        func getCurrentTheme() -> ColorTheme {
            APP.themeManager.getCurrentTheme()
        }
        
        func isUsingDeviceValues() -> Bool {
            APP.themeManager.isUsingDeviceValues()
        }
    }
    
   
}
