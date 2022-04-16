//
//  TodayDetailRouter.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit

class TodayDetailRouter {

    func showShareSheet(eksiLink: String) {
        let activityViewController = UIActivityViewController(activityItems: [eksiLink], applicationActivities: nil)
        ERNavUtility.showActivityViewController(activityViewController)
    }
}
