//
//  ERListView.swift
//  EksiReader
//
//  Created by aybek can kaya on 13.04.2022.
//

import Foundation
import UIKit

typealias ERListCallback<C: ERListCell, T: DeclarativeListItem> = (ERListView<C, T>) -> Void
typealias ERListItemSelectedCallback<C: ERListCell, T: DeclarativeListItem> = (ERListView<C, T>, IndexPath, T) -> Void

class ERListView<C: ERListCell, T: DeclarativeListItem>: UIView {

    private let tableViewItems: DeclarativeTableView<C, T> =
    DeclarativeTableView<C, T>
        .declarativeTableView()

    private let refreshControl = UIRefreshControl()

    private var loadNewItemsCallback: ERListCallback<C, T>?
    private var refreshItemsCallback: ERListCallback<C, T>?
    private var itemsSelectedCallback: ERListItemSelectedCallback<C, T>?

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {

        tableViewItems.backgroundColor = .clear
        tableViewItems
            .add(into: self)
            .fit()

        let refreshViewFrame = CGRect(origin: .zero, size: .init(width: self.frame.size.width, height: 64))
        let refreshView = EksiFooterLoadingView(frame: refreshViewFrame)
        refreshView.backgroundColor = Styling.Application.backgroundColor
        refreshControl.addSubview(refreshView)
        tableViewItems.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshItems), for: .valueChanged)

        tableViewItems
            .cellAtIndex { tableView, cell, presentation, IndexPath in
                cell.configure(with: presentation as! C.T)
            }.didSelectCell { tableView, presentation, indexPath in
                self.itemsSelectedCallback?(self, indexPath, presentation)
                //self.viewModel.selectItem(withIdentifier: presentation.id)
            }

    }

    func configure(with items: [T]) {
        self.tableViewItems.updateItems(items)
        self.refreshControl.endRefreshing()
    }

    @discardableResult
    func loadNewItems(_ callback: ERListCallback<C, T>?) -> ERListView<C, T> {
        self.loadNewItemsCallback = callback
        return self
    }

    @discardableResult
    func resetItems(_ callback: ERListCallback<C, T>?) -> ERListView<C, T> {
        self.refreshItemsCallback = callback
        return self
    }

    func updateFooterViewVisibility(isVisible: Bool) {
        tableViewItems
            .footerView {
                guard isVisible else { return nil }
                let frame = CGRect(origin: .zero, size: .init(width: self.tableViewItems.frame.size.width, height: 64))
                let view = EksiFooterLoadingView(frame: frame)
                return view
            }
    }

    func fetchNewItemsEnabled(isEnabled: Bool) {
        if isEnabled {
            tableViewItems
                .willDisplayLastCell { tableView, cell, presentation, indexPath in
                    NSLog("Last Cell Visible")
                    self.loadNewItemsCallback?(self)
            }
        } else {
            tableViewItems.willDisplayLastCell(nil)
        }
    }

    @objc private func refreshItems() {
        self.refreshItemsCallback?(self)
//        var _viewModel = viewModel
//        _viewModel.resetEntries()
//        _viewModel.loadNewItems()
    }
}
