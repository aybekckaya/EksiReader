//
//  SettingsDetailViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

class SettingsDetailViewModel {
    enum Const {
        static let useDeviceValuesKey = "UseDeviceSwitcher"
        static let lightThemeTickKey = "LightThemeTick"
        static let darkThemeTickKey = "DarkThemeTick"
    }
    
    private let router: SettingsDetailRouter
    private let dataController: SettingsDetailDataController

    private var currentPresentation: SettingsDetailPresentation = .init()

    enum Change {
        case title(title: String)
        case presentation(presentation: SettingsDetailPresentation)
        case reload(presentation: SettingsDetailPresentation)
    }

    var changeHandler: ((Change) -> Void)?

    var osTheme: UIUserInterfaceStyle {
        return UIScreen.main.traitCollection.userInterfaceStyle
    }
    
    init(dataController: SettingsDetailDataController, router: SettingsDetailRouter) {
        self.dataController = dataController
        self.router = router 
    }

}

// MARK: - Public
extension SettingsDetailViewModel {
    func initialize() {
        let currentItem = dataController.getItem()
        handleSettingsItem(currentItem)
        trigger(.title(title: currentItem.title))
    }
    
    func valueChanged(identifier: String, newValue: Any?) {
        settingsValueChanged(identifier: identifier, newValue: newValue)
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
        let isUsingDeviceValues = dataController.colorTheme.isUsingDeviceValues()
        let currentColorTheme = dataController.colorTheme.getCurrentTheme()
        
        let switcher = SwitcherInputPresentation()
        switcher.identifier = Const.useDeviceValuesKey
        switcher.title = "Cihaz ayarlarını kullan"
        switcher.description = nil
        switcher.isOn = isUsingDeviceValues
        switcher.isEnabled = true
        
        let sectionDeviceValues = SettingsDetailInputSection()
        sectionDeviceValues.inputs = [switcher]
        
        let lightThemePresentation = TickInputPresentation()
        lightThemePresentation.identifier = Const.lightThemeTickKey
        lightThemePresentation.title = "Açık"
        lightThemePresentation.description = nil
        lightThemePresentation.isChecked = currentColorTheme.identifier == LightColorTheme().identifier
        lightThemePresentation.isEnabled = !isUsingDeviceValues
        
        let darkThemePresentation = TickInputPresentation()
        darkThemePresentation.identifier = Const.darkThemeTickKey
        darkThemePresentation.title = "Koyu"
        darkThemePresentation.description = nil
        darkThemePresentation.isChecked = currentColorTheme.identifier == DarkColorTheme().identifier
        darkThemePresentation.isEnabled = !isUsingDeviceValues
        
       let sectionThemes = SettingsDetailInputSection()
        sectionThemes.inputs = [lightThemePresentation, darkThemePresentation]
        
        currentPresentation = SettingsDetailPresentation()
        currentPresentation.sections = [sectionDeviceValues, sectionThemes]
        
        trigger(.presentation(presentation: currentPresentation))
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

// MARK: - Settings Value Change
extension SettingsDetailViewModel {
    private func settingsValueChanged(identifier: String, newValue: Any?) {
        //guard let item = findItemPresentation(with: identifier) else { return }
        if let switcherPresentation: SwitcherInputPresentation = findItemPresentation(with: identifier),
           let value = newValue as? Bool {
            switcherValueChanged(presentation: switcherPresentation, newValue: value)
        } else if let tickPresentation: TickInputPresentation = findItemPresentation(with: identifier) {
            tickViewDidTapped(presentation: tickPresentation)
        }
    }
    
    private func findItemPresentation<T: SettingsDetailInputPresentation>(with identifier: String) -> T? {
        return currentPresentation
            .sections.first {
                $0.inputs.first { $0.identifier == identifier } != nil
            }?.inputs.first { $0.identifier == identifier } as? T
    }
    
    private func switcherValueChanged(presentation: SwitcherInputPresentation, newValue: Bool) {
        if presentation.identifier == Const.useDeviceValuesKey {
            var darkThemePresentation: TickInputPresentation? = findItemPresentation(with: Const.darkThemeTickKey)
            var lightThemePresentation: TickInputPresentation? = findItemPresentation(with: Const.lightThemeTickKey)
            presentation.isOn = newValue
            dataController.colorTheme.shouldUseDeviceValues(newValue)
            if newValue == true {
                lightThemePresentation?.isEnabled = false
                darkThemePresentation?.isEnabled = false
            } else {
                lightThemePresentation?.isEnabled = true
                darkThemePresentation?.isEnabled = true 
            }
        }
        trigger(.reload(presentation: currentPresentation))
    }
    
    private func tickViewDidTapped(presentation: TickInputPresentation) {
        if presentation.identifier == Const.lightThemeTickKey {
            dataController.colorTheme.setColorTheme(LightColorTheme())
            let darkThemePresentation: TickInputPresentation? = findItemPresentation(with: Const.darkThemeTickKey)
            let lightThemePresentation: TickInputPresentation? = findItemPresentation(with: Const.lightThemeTickKey)
            darkThemePresentation?.isChecked = false
            lightThemePresentation?.isChecked = true
        
        } else if presentation.identifier == Const.darkThemeTickKey {
            dataController.colorTheme.setColorTheme(DarkColorTheme())
            let darkThemePresentation: TickInputPresentation? = findItemPresentation(with: Const.darkThemeTickKey)
            let lightThemePresentation: TickInputPresentation? = findItemPresentation(with: Const.lightThemeTickKey)
            darkThemePresentation?.isChecked = true
            lightThemePresentation?.isChecked = false
        }
        
        trigger(.reload(presentation: currentPresentation))
    }
}
