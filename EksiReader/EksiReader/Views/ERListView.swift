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
typealias ERListItemInputSelectedCallback<C: ERListCell, T: DeclarativeListItem> = (ERListView<C, T>, Int) -> Void

class ERListView<C: ERListCell, T: DeclarativeListItem>: UIView, TopicCellDelegate {

    private let tableViewItems: DeclarativeTableView<C, T> =
    DeclarativeTableView<C, T>
        .declarativeTableView()

    private let refreshControl = UIRefreshControl()

    private var loadNewItemsCallback: ERListCallback<C, T>?
    private var refreshItemsCallback: ERListCallback<C, T>?
    private var itemsSelectedCallback: ERListItemSelectedCallback<C, T>?
    private var favoriteDidTappedCallback: ERListItemInputSelectedCallback<C, T>?
    private var shareDidTappedCallback: ERListItemInputSelectedCallback<C, T>?

    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {

        tableViewItems.separatorStyle = .singleLine
        tableViewItems.separatorColor = .white.withAlphaComponent(0.5)
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
                if let cell = cell as? TopicCell {
                    cell.setDelegate(self)
                }
            }.didSelectCell { tableView, presentation, indexPath in
                self.itemsSelectedCallback?(self, indexPath, presentation)
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

    @discardableResult
    func selectedItem(_ callback: ERListItemSelectedCallback<C,T>?) -> ERListView<C, T> {
        self.itemsSelectedCallback = callback
        return self
    }

    @discardableResult
    func shareItem(_ callback: ERListItemInputSelectedCallback<C,T>?) -> ERListView<C, T> {
        self.shareDidTappedCallback = callback
        return self
    }

    @discardableResult
    func favoriteItem(_ callback: ERListItemInputSelectedCallback<C,T>?) -> ERListView<C, T> {
        self.favoriteDidTappedCallback = callback
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

    func topicCellDidTappedShare(_ cell: TopicCell, entryId: Int) {
        shareDidTappedCallback?(self, entryId)
    }

    func topicCellDidTappedFavorite(_ cell: TopicCell, entryId: Int) {
        favoriteDidTappedCallback?(self, entryId)
    }
}
