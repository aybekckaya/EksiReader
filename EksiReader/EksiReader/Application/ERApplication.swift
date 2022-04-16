//
//  ERApplication.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

let APP = ERApplication()

class ERApplication {
    let storage = ERStorage()
}

// MARK: - Public
extension ERApplication {
    func initialize() {
        storage.initialize()
    }

    func deInitialize() {
        storage.deinitialize()
    }
}
