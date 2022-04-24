//
//  File.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit
import Loaf

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
        _listView
            .add(into: self.view)
            .fit()

        _listView
            .sortingType(.lastToFirst)
            .loadNewItems { _ in
                var _viewModel = self.viewModel
                _viewModel.loadNewItems()
            }.resetItems { _ in
                var _viewModel = self.viewModel
                _viewModel.resetEntries()
                _viewModel.loadNewItems()
            }.selectedItem { _, indexPath, presentation in
                let _viewModel = self.viewModel
                _viewModel.navigateToEntryViewController(entryId: presentation.id)
            }.favoriteItem { [weak self] _, entryId in
                self?.viewModel.favorite(id: entryId)
            }.shareItem { [weak self] _, entryId in
                self?.viewModel.share(id: entryId)
            }.reportItem { [weak self] _, entryId in
                NSLog("REPORT: \(entryId)")
            }.visiblePage { _, presentations in
                self.viewModel.visiblePresentations(presentations)
            }
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
        var _viewModel = viewModel
        _viewModel.bind { change in
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
