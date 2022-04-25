//
//  SearchViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 24.04.2022.
//

import Foundation
import UIKit

class SettingsViewController: ERViewController {
    private let viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
    }
}

// MARK: - Listeners
extension SettingsViewController {
    private func addListeners() {

    }
}


// MARK: - Set Up UI
extension SettingsViewController {
    private func setUpUI() {
        self.setTitle("Ayarlar")
        self.view.backgroundColor = Styling.Application.backgroundColor
    }
}


