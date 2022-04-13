//
//  TodayVC.swift
//  EksiReader
//
//  Created by aybek can kaya on 5.04.2022.
//

import Foundation
import UIKit




class TodayVC: ERViewController {
    private let viewModel: TodayViewModel
    private let listView: ERListView<TodayCell, TodayPresentation> = .init()

//    private let tableViewToday: DeclarativeTableView<TodayCell, TodayPresentation> =
//    DeclarativeTableView<TodayCell, TodayPresentation>
//        .declarativeTableView()

    // private let refreshControl = UIRefreshControl()

    init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Lifecycle
extension TodayVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
        var _viewModel = viewModel
        _viewModel.loadNewItems()
    }
}

// MARK: - Set Up UI
extension TodayVC {
    private func setUpUI() {
        title = "Güncel"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

        listView
            .add(into: self.view)
            .fit()

        listView
            .loadNewItems { list in
                var _viewModel = self.viewModel
                _viewModel.loadNewItems()
            }.resetItems { list in
                self.refreshItems()
            }

    }
}

// MARK: - Actions
extension TodayVC {
    @objc private func refreshItems() {
        var _viewModel = viewModel
        _viewModel.resetEntries()
        _viewModel.loadNewItems()
    }
}

// MARK: - Listeners
extension TodayVC {
    private func addListeners() {
        var _viewModel = viewModel
        _viewModel.bind { [weak self] change in
            self?.handle(change)
        }
    }
}

// MARK: - Handle Change Handler Data
extension TodayVC {
    private func handle(_ change: PagableViewModelChange<TodayPresentation>) {
        switch change {
        case .loading(let isVisible):
            isVisible ? EksiLoadingView.show() : EksiLoadingView.hide()
        case .footerViewLoading(let isVisible):
            listView.updateFooterViewVisibility(isVisible: isVisible)
        case .presentations(let itemPresentations):
            listView.configure(with: itemPresentations)
        case .error(let error):
            break
        case .fetchNewItemsEnabled(let isEnabled):
            listView.fetchNewItemsEnabled(isEnabled: isEnabled)
        }
    }
}

// MARK: -
extension TodayVC {

}

// MARK: -
extension TodayVC {

}

// MARK: -
extension TodayVC {

}

// MARK: -
extension TodayVC {

}

// MARK: -
extension TodayVC {

}

// MARK: -
extension TodayVC {

}

