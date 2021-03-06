//
//  ERListView.swift
//  EksiReader
//
//  Created by aybek can kaya on 13.04.2022.
//

import Foundation
import UIKit

typealias ERListCallback<C: ERListCell, T: PagableListItem> = (ERListView<C, T>) -> Void
typealias ERListItemSelectedCallback<C: ERListCell, T: PagableListItem> = (ERListView<C, T>, IndexPath, T) -> Void
typealias ERListItemInputSelectedCallback<C: ERListCell, T: PagableListItem> = (ERListView<C, T>, Int) -> Void
typealias ERListItemVisibleCellsCallback<C: ERListCell, T: PagableListItem> = (ERListView<C, T>, [T]) -> Void

class ERListView<C: ERListCell, T: PagableListItem>: UIView, EntryContentViewDelegate {

    private let tableViewItems: DeclarativeTableView<C, T> =
    DeclarativeTableView<C, T>
        .declarativeTableView()

    private let refreshControl = LottieRefreshControl()

    private var sortingType: ERListSortType = .firstToLast

    private var loadNewItemsCallback: ERListCallback<C, T>?
    private var refreshItemsCallback: ERListCallback<C, T>?
    private var itemsSelectedCallback: ERListItemSelectedCallback<C, T>?
    private var favoriteDidTappedCallback: ERListItemInputSelectedCallback<C, T>?
    private var shareDidTappedCallback: ERListItemInputSelectedCallback<C, T>?
    private var reportDidTappedCallback: ERListItemInputSelectedCallback<C, T>?
    private var authorDidTappedCallback: ERListItemInputSelectedCallback<C, T>?
    private var visiblePageCallback: ERListItemVisibleCellsCallback<C, T>?

    init() {
        super.init(frame: .zero)
        setUpUI()
        addListeners()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func addListeners() {

        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.changedEntryFollowStatus, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.tableViewItems.reload()
        }

        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.colorThemeChanged, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.tableViewItems.reload()
        }
    }

    private func setUpUI() {
        tableViewItems.separatorStyle = .none
        tableViewItems.separatorColor = .white.withAlphaComponent(0.5)
        tableViewItems.separatorInset = .init(top: 0, left: -16, bottom: 0, right: 0)
        tableViewItems.backgroundColor = .clear
        tableViewItems
            .add(into: self)
            .fit()

        tableViewItems.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshItems), for: .valueChanged)

        tableViewItems
            .cellAtIndex { [weak self] tableView, cell, presentation, IndexPath in
                guard let self = self else { return }
                cell.configure(with: presentation as! C.T)
                if let cell = cell as? TopicCell {
                    cell.setDelegate(self)
                }
                cell.updateTheme()
            }.didSelectCell {  [weak self] tableView, presentation, indexPath in
                guard let self = self else { return }
                self.itemsSelectedCallback?(self, indexPath, presentation)
            }.didScrollTable {[weak self]  tableView, offset in
                guard let self = self else { return }
               self.refreshControl.updateProgress(with: offset.y)
            }.visibleCells { [weak self] tableView, cells, items, indexPaths in
                guard let self = self else { return }
                self.callVisiblePageCallback(items: items)
            }
    }

    private func callVisiblePageCallback(items: [T]) {
        guard
            let visiblePageCallback = visiblePageCallback,
            items.count > 0
        else { return }
        visiblePageCallback(self, items)
    }

    func setTopContentInset(_ value: CGFloat) {
        self.tableViewItems.contentInset = UIEdgeInsets(top: value,
                                                        left:  self.tableViewItems.contentInset.left,
                                                        bottom:  self.tableViewItems.contentInset.bottom,
                                                        right:  self.tableViewItems.contentInset.bottom)
    }

    func getItems() -> [T] {
        return self.tableViewItems.items
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
    func visiblePage(_ callback: ERListItemVisibleCellsCallback<C, T>?) -> ERListView<C, T> {
        self.visiblePageCallback = callback
        return self
    }

    @discardableResult
    func sortingType(_ value: ERListSortType) -> ERListView<C, T> {
        self.sortingType = value 
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

    @discardableResult
    func reportItem(_ callback: ERListItemInputSelectedCallback<C,T>?) -> ERListView<C, T> {
        self.reportDidTappedCallback = callback
        return self
    }

    @discardableResult
    func selectedAuthor(_ callback: ERListItemInputSelectedCallback<C,T>?) -> ERListView<C, T> {
        self.authorDidTappedCallback = callback
        return self
    }

    func updateFooterViewVisibility(isVisible: Bool) {
        tableViewItems
            .footerView {
                return nil
            }
    }

    func fetchNewItemsEnabled(isEnabled: Bool) {
        if isEnabled {
            tableViewItems
                .willDisplayLastCell { [weak self] tableView, cell, presentation, indexPath in
                    guard let self = self else { return }
                    NSLog("Last Cell Visible")
                    self.loadNewItemsCallback?(self)
            }
        } else {
            tableViewItems.willDisplayLastCell(nil)
        }
    }

    @objc private func refreshItems() {
        self.refreshItemsCallback?(self)
    }

    func entryContentViewDidTappedShare(_ view: EntryContentView, entryId: Int) {
        shareDidTappedCallback?(self, entryId)
    }

    func entryContentViewDidTappedFavorite(_ view: EntryContentView, entryId: Int) {
        favoriteDidTappedCallback?(self, entryId)
    }

    func entryContentViewDidTappedReport(_ view: EntryContentView, entryId: Int) {
        reportDidTappedCallback?(self, entryId)
    }

    func entryContentViewDidTappedAuthorInfo(_ view: EntryContentView, authorId: Int) {
        authorDidTappedCallback?(self, authorId)
    }
}
