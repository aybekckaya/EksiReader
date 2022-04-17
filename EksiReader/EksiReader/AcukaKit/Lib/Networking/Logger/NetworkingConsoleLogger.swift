//
//  NetworkingConsoleLogger.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 2.04.2022.
//

import Foundation

class NetworkingConsoleLogger: NetworkingLogProvider {
    var enabledLogTypes: [NetworkingLogType] {
        _enabledLogTypes
    }

    private var _enabledLogTypes: [NetworkingLogType] = []

    required init(enabledLogTypes: [NetworkingLogType]) {
        self._enabledLogTypes = enabledLogTypes
    }

    func log(_ value: Any?) {
        guard let value = value else { return }
        NSLog("\(value)")
    }

}
