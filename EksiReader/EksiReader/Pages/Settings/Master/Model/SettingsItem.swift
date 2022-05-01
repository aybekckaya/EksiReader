//
//  SettingItem.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

enum SettingsItem: Int {
    case theme = 1
    case textSize = 2
}

// MARK: - Icon
extension SettingsItem {
    var icon: String {
        switch self {
        case .theme:
            return "paintbrush.pointed"
        case .textSize:
            return "textformat.size"
        }
    }
}

// MARK: - Title
extension SettingsItem {
    var title: String {
        switch self {
        case .theme:
            return "Tema"
        case .textSize:
            return "Yazı Boyutu"
        }
    }
}

// MARK: - Description
extension SettingsItem {
    var settingsDescription: String {
        switch self {
        case .theme:
            return "Cihazınızda kullandığınız temayı kullanabilir veya size özel temalardan birini seçebilirsiniz."
        case .textSize:
            return "Yazı boyutunu buradan değiştirebilirsiniz. Varsayılan değer olarak, cihazınızda kullandığınız erişilebilirlik değerleri alınacaktır."
        }
    }
}
