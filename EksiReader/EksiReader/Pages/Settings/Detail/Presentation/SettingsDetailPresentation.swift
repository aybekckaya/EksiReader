//
//  SettingsDetailPresenter.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

protocol SettingsDetailInputPresentation {
    var identifier: String { get set }
    var title: String { get set }
    var description: String? { get set }
    var isEnabled: Bool { get set }
}

class SwitcherInputPresentation: SettingsDetailInputPresentation {
    var isEnabled: Bool = false
    var identifier: String = ""
    var title: String = ""
    var description: String? = nil
    var isOn: Bool = false
}

class TickInputPresentation: SettingsDetailInputPresentation {
    var isEnabled: Bool = false
    var identifier: String = ""
    var title: String = ""
    var description: String? = nil
    var isChecked: Bool = false
}

class SettingsDetailInputSection {
    var inputs: [SettingsDetailInputPresentation] = []
}

class SettingsDetailPresentation {
    var sections: [SettingsDetailInputSection] = []
}
