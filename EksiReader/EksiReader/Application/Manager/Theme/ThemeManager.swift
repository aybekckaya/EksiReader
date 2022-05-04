//
//  ThemeManager.swift
//  EksiReader
//
//  Created by Kaya, Can(AWF) on 4.05.2022.
//

import Foundation
import UIKit

class ThemeManager {
    let availableThemes: [ColorTheme] = [LightColorTheme(), DarkColorTheme()]
}

// MARK: - Public
extension ThemeManager {
    func isUsingDeviceValues() -> Bool {
        if UserDefaults.standard.dictionaryRepresentation().keys.contains(ERKey.usesDeviceConstantsThemeKey) {
            return UserDefaults.standard.bool(forKey: ERKey.usesDeviceConstantsThemeKey)
        } else {
            return true
        }
    }
    
    func setIsUsingDeviceValues(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: ERKey.usesDeviceConstantsThemeKey)
        UserDefaults.standard.synchronize()
    }
    
    func setCurrentTheme(_ value: ColorTheme) {
        setIsUsingDeviceValues(false)
        UserDefaults.standard.set(value.identifier, forKey: ERKey.currentThemeKey)
        UserDefaults.standard.synchronize()
    }
    
    func getCurrentTheme() -> ColorTheme {
        if isUsingDeviceValues() {
            let theme = UIScreen.main.traitCollection.userInterfaceStyle
            if theme == .dark { return DarkColorTheme() }
            else if theme == .light { return LightColorTheme() }
        }
        guard let themeIdentifier = UserDefaults.standard.string(forKey: ERKey.currentThemeKey)
        else {  return availableThemes.first! }
        if let theme = availableThemes.first { $0.identifier == themeIdentifier } {
            return theme
        }
        return availableThemes.first!
    }
}
