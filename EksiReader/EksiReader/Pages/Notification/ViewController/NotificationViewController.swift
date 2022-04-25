//
//  NotificationViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 25.04.2022.
//

import Foundation
import UIKit

class NotificationViewController: ERViewController {
    private let viewModel: NotificationViewModel

    init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension NotificationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
}

// MARK: - Set Up UI
extension NotificationViewController {
    private func setUpUI() {
        self.setTitle("Bildirimler")
    }
}

// MARK: -
extension NotificationViewController {

}

// MARK: -
extension NotificationViewController {

}

// MARK: -
extension NotificationViewController {

}

// MARK: -
extension NotificationViewController {

}

// MARK: -
extension NotificationViewController {

}

