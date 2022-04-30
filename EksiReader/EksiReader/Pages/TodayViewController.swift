//
//  TodayViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 20.04.2022.
//

import Foundation
import UIKit

class TodayViewController: TopicListViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EksiAnalytics.screenAppear(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        EksiAnalytics.screenDissapear(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

