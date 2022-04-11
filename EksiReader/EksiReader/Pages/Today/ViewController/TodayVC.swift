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

    private let tableViewToday: DeclarativeTableView<TodayCell, TodayPresentation> =
    DeclarativeTableView<TodayCell, TodayPresentation>
        .declarativeTableView()

    private let refreshControl = UIRefreshControl()

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
        viewModel.loadNewItems()
    }
}

// MARK: - Set Up UI
extension TodayVC {
    private func setUpUI() {
        title = "Güncel"
       // navigationController?.hidesBarsOnSwipe = true
        tableViewToday.backgroundColor = .clear
        tableViewToday
            .add(into: self.view)
            .fit()


        let refreshViewFrame = CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 64))
        let refreshView = EksiFooterLoadingView(frame: refreshViewFrame)
        refreshView.backgroundColor = Styling.Application.backgroundColor
        refreshControl.addSubview(refreshView)
        tableViewToday.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
    }
}

// MARK: - Actions
extension TodayVC {
    @objc private func refreshItems() {
        viewModel.resetEntries()
        viewModel.loadNewItems()
    }
}

// MARK: - Listeners
extension TodayVC {
    private func addListeners() {
        viewModel.bind { [weak self] change in
            self?.handle(change)
        }

        tableViewToday
            .cellAtIndex { tableView, cell, presentation, IndexPath in
                cell.configure(presentation)
            }.didSelectCell { tableView, presentation, indexPath in
                NSLog("Selected: \(presentation)")
            }.willDisplayLastCell { tableView, cell, presentation, indexPath in
                self.viewModel.loadNewItems()
            }
    }
}


// MARK: - Handle Change Handler Data
extension TodayVC {
    private func handle(_ change: TodayViewModel.Change) {
        switch change {
        case .loading(let isVisible):
            isVisible ? EksiLoadingView.show() : EksiLoadingView.hide()
        case .footerViewLoading(let isVisible):
            tableViewToday
                .footerView {
                    guard isVisible else { return nil }
                    let frame = CGRect(origin: .zero, size: .init(width: self.tableViewToday.frame.size.width, height: 64))
                    let view = EksiFooterLoadingView(frame: frame)
                    return view
                }
        case .presentations(let itemPresentations):
            self.refreshControl.endRefreshing()
            tableViewToday.updateItems(itemPresentations)
        case .error(let error):
            break
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

