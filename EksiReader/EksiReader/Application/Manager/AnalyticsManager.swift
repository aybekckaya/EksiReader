//
//  AnalyticsManager.swift
//  EksiReader
//
//  Created by aybek can kaya on 30.04.2022.
//

import Foundation
import Firebase
import UIKit

let EksiAnalytics = AnalyticsManager()

enum AnalyticsManagerKey: String {
    case screenAppear = "EksiScreenAppear"
    case screenDisAppear = "EksiScreenDisAppear"
}

// MARK: - Analytics Manager
class AnalyticsManager {
    enum Const {
        static let userId = "EksiUserId"
        static let view = "EksiView"
    }

    private var userId: String = ""

    init() {
        initializeUserId()
    }
}

// MARK: - User Id
extension AnalyticsManager {
    private func initializeUserId() {
        if let userId = UserDefaults.standard.string(forKey: "AnalyticsEksiUserId") {
            self.userId = userId
        } else {
            userId = UUID().uuidString
            UserDefaults.standard.set(userId, forKey: "AnalyticsEksiUserId")
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - Log Events
extension AnalyticsManager {
    func logEvent(name: String, parameters: [String: Any?]?) {
        guard let parameters = parameters else {
            Analytics.logEvent(name, parameters: [Const.userId: userId])
            return
        }
        var flatParameters = flattenParameters(parameters: parameters)
        flatParameters[Const.userId] = userId
        Analytics.logEvent(name, parameters: flatParameters)
    }

    private func flattenParameters(parameters: [String: Any?]) -> [String: Any] {
        var flatParameters: [String: Any] = [:]
        parameters.keys.forEach {
            if let value = parameters[$0] as? NSObject {
                flatParameters[$0] = value
            }
        }
        return flatParameters
    }
}

// MARK: - Screen View
extension AnalyticsManager {
    func screenAppear(_ viewController: UIViewController) {
        logEvent(name: AnalyticsManagerKey.screenAppear.rawValue, parameters: [
            Const.view: viewController.className
        ])
    }

    func screenDissapear(_ viewController: UIViewController) {
        logEvent(name: AnalyticsManagerKey.screenDisAppear.rawValue, parameters: [
            Const.view: viewController.className
        ])
    }
}

extension UIViewController {
    var className: String {
        NSStringFromClass(self.classForCoder).components(separatedBy: ".").last!
    }
}
