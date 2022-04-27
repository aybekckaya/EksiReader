//
//  ReportRouter.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation

class ReportRouter {
    func dismissReportViewController() {
        guard let visibleViewController = ERNavUtility.topMostViewController() else { return }
        visibleViewController.dismiss(animated: true) {
            NotificationCenter.default.post(name: ERKey.NotificationName.reloadTopicEntries, object: nil)
        }
    }
}
