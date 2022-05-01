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

    private let tableViewSettings: DeclarativeTableView<SettingsCell, SettingsItemPresentation> = DeclarativeTableView<SettingsCell, SettingsItemPresentation>.declarativeTableView()

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
        viewModel.initialize()
    }
}

// MARK: - Listeners
extension SettingsViewController {
    private func addListeners() {
        viewModel.changeHandler = { [weak self] change in
            self?.handleChange(change)
        }
    }
}

// MARK: - Handle Change
extension SettingsViewController {
    private func handleChange(_ change: SettingsViewModelChange<SettingsPresentation>) {
        switch change {
        case .error(let error):
            break
        case .loading(let isVisible):
            break
        case .presentation(let itemPresentation):
            tableViewSettings.updateItems(itemPresentation.items)
        case .title(let title):
            self.setTitle(title)
        }
    }
}

// MARK: - Set Up UI
extension SettingsViewController {
    private func setUpUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        tableViewSettings.contentInset = .init(top: 64, left: 0, bottom: 0, right: 0)
        tableViewSettings
            .add(into: self.view)
            .fit()
        tableViewSettings.backgroundColor = .clear
        tableViewSettings.seperatorStyle(.none)

        tableViewSettings.cellAtIndex { table, cell, presentation, IndexPath in
            cell.configureCell(presentation: presentation)
        }.didSelectCell { table, presentation, indexPath in
            self.viewModel.selectedItem(presentation)
        }
    }
}


