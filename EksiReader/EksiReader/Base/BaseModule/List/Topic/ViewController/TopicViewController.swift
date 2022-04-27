//
//  File.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit
import Loaf
import SwiftEntryKit

class TopicViewController: ERViewController, PagableViewController {

    typealias Cell = TopicCell
    typealias PresentationItem = TopicItemPresentation
    typealias ViewModel = TopicViewModel

    var _viewModel: TopicViewModel { viewModel }
    var showsPagingIndicatorView: Bool { true }
    var pageIndicatorView: ERPagingView? { _pageIndicatorView }
    var listView: ERListView<Cell, PresentationItem> { _listView }

    private let viewModel: TopicViewModel
    private let _listView: ERListView<TopicCell, TopicItemPresentation> = .init()
    private let _pageIndicatorView = ERPagingView.erPagingView()

    init(viewModel: TopicViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension TopicViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        initializePagableViewController()
        addListeners()

        var _viewModel = viewModel
        _viewModel.loadNewItems()
    }
}

// MARK: - Set Up UI
extension TopicViewController {
    private func setUpUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

//        let imageSort = UIImage(systemName: "arrow.up.arrow.down")!
//        let sortButtonItem = UIBarButtonItem(image: imageSort, style: .plain, target: self, action: #selector(sortingDidTapped))
//        let imageWatch = UIImage(systemName: "eye")!
//        let watchButtonItem = UIBarButtonItem(image: imageWatch, style: .plain, target: self, action: #selector(sortingDidTapped))
//        navigationItem.rightBarButtonItems = [sortButtonItem, watchButtonItem]

        let imageSort = UIImage(systemName: "circle.grid.3x3")!
        let sortButtonItem = UIBarButtonItem(image: imageSort, style: .plain, target: self, action: #selector(menuViewDidTapped(_:)))
        navigationItem.rightBarButtonItem = sortButtonItem

        _listView
            .add(into: self.view)
            .fit()

        _listView
            .sortingType(.lastToFirst)
            .loadNewItems { [weak self] _ in
                guard let self = self else { return }
                var _viewModel = self.viewModel
                _viewModel.loadNewItems()
            }.resetItems { [weak self] _ in
                guard let self = self else { return }
                var _viewModel = self.viewModel
                _viewModel.resetEntries()
                _viewModel.loadNewItems()
            }.selectedItem { _, indexPath, presentation in
//                let _viewModel = self.viewModel
//                _viewModel.navigateToEntryViewController(entryId: presentation.id)
            }.favoriteItem { [weak self] _, entryId in
                self?.viewModel.favorite(id: entryId)
            }.shareItem { [weak self] _, entryId in
                self?.viewModel.share(id: entryId)
            }.reportItem { [weak self] _, entryId in
                self?.viewModel.navigateToReport(entryId: entryId)
            }.visiblePage { [weak self] _, presentations in
                self?.viewModel.visiblePresentations(presentations)
            }.selectedAuthor { [weak self]  _, authorId in
                self?.viewModel.navigateToAuthorInfo(authorId: authorId)
            }

        _listView.backgroundColor = .clear
    }
}

// MARK: - Actions
extension TopicViewController {
    @objc private func menuViewDidTapped(_ sender: UIBarButtonItem) {
        viewModel.navigateToFilterOptions()
    }

    @objc private func sortingDidTapped() {
        viewModel.toggleSortingType()
    }
}

// MARK: - UI Update
extension TopicViewController {
    private func showToast(message: String) {
        Loaf(message,
             presentingDirection: .vertical,
             dismissingDirection: .vertical,
             sender: self).show()
    }
}

// MARK: - Listeners
extension TopicViewController {
    private func addListeners() {
        let _viewModel = viewModel
        _viewModel.bind { [weak self] change in
            guard let self = self else { return }
            switch change {
            case .title(let title):
                self.setTitle(title)
            case .fetchNewItemsEnabled(let isEnabled):
                self._listView.fetchNewItemsEnabled(isEnabled: isEnabled)
            case .error(let error):
                break
            case .footerViewLoading(let isVisible):
                self._listView.updateFooterViewVisibility(isVisible: isVisible)
            case .loading(let isVisible):
                isVisible ? self.showFullSizeLoading() : self.hideFullSizeLoading()

            case .presentations( _):
                let updatedPresentations = self.viewModel.updatedPresentations()
                self._listView.configure(with: updatedPresentations)
            case .reloadItemsAtIndexes(let indexes):
                break
            case .infoToast( let message):
                self.showToast(message: message)
            case .pages(currentPage: let currentPage, totalPage: let totalPage):
                self.pageIndicatorView?.updateTitle(currentPage: currentPage, totalPage: totalPage)
            }
        }
    }
}
