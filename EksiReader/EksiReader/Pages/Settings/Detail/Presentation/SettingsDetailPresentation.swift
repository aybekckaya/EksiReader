//
//  SettingsDetailPresenter.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import UIKit

protocol SettingsDetailInputPresentation {

}

struct SwitcherInputPresentation: SettingsDetailInputPresentation {
    let identifier: String
    let title: String
    let description: String?
    let isOn: Bool
}

struct SettingsDetailInputSection {
    let inputs: [SettingsDetailInputPresentation]
}

struct SettingsDetailPresentation {
    let sections: [SettingsDetailInputSection]
}
