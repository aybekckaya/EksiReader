//
//  TodayVC.swift
//  EksiReader
//
//  Created by aybek can kaya on 5.04.2022.
//

import Foundation
import UIKit
import Firebase

class TopicListViewController: ERViewController, PagableViewController {

    typealias Cell = TopicListCell
    typealias PresentationItem = TopicListItemPresentation
    typealias ViewModel = TopicListViewModel

    let _viewModel: ViewModel

    var viewModel: ViewModel { _viewModel }
    var showsPagingIndicatorView: Bool { true }
    var pageIndicatorView: ERPagingView? { _pageIndicatorView }
    var listView: ERListView<Cell, PresentationItem> { _listView }

    private let _pageIndicatorView = ERPagingView.erPagingView()
    private let _listView: ERListView<Cell, PresentationItem> = .init()

    init(viewModel: ViewModel) {
        self._viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Lifecycle
extension TopicListViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageIndicatorView?.updateTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
          AnalyticsParameterItemID: "ItemID-Aybek",
          AnalyticsParameterItemName: "TopicListViewController",
          AnalyticsParameterContentType: "Content",
        ])

        setUpUI()
        initializePagableViewController()
        addListeners()

        let _viewModel = _viewModel
        _viewModel.loadNewItems()
        _viewModel.initializeViewModel()
    }
}

// MARK: - Set Up UI
extension TopicListViewController {
    private func setUpUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)

        _listView
            .add(into: self.view)
            .fit()

        _listView
            .loadNewItems { list in
                let _viewModel = self._viewModel
                _viewModel.loadNewItems()
            }.resetItems { list in
                self.refreshItems()
            }.selectedItem { list, indexPath, presentation in
                //var _viewModel = self.viewModel
                self._viewModel.selectItem(withIdentifier: presentation.id)
            }.visiblePage { _, presentations in
                self.viewModel.visiblePresentations(presentations)
            }
    }
}

// MARK: - Actions
extension TopicListViewController {
    @objc private func refreshItems() {
        let _viewModel = _viewModel
        _viewModel.resetEntries()
        _viewModel.loadNewItems()
    }
}

// MARK: - Listeners
extension TopicListViewController {
    private func addListeners() {
        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.colorThemeChanged, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            self.pageIndicatorView?.updateTheme()
        }

        let _viewModel = _viewModel
        _viewModel.bind { [weak self] change in
            self?.handle(change)
        }

        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.reloadTopicList, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else { return }
            if let _ = notification.object as? TopicFollowStatusNotificationModel {
                let storage = APP.storage
                
                let newPresentations: [TopicListItemPresentation] = self._listView
                    .getItems()
                    .compactMap {
                        var presentation = $0
                        let isFollowing = storage.isEntryFollowing(entryId: $0.id)
                        presentation.setIsFollowing(isFollowing)
                        return presentation
                }
                self.listView.configure(with: newPresentations)
            }
        }
    }
}

// MARK: - Handle Change Handler Data
extension TopicListViewController {
    private func handle(_ change: PagableViewModelChange<TopicListItemPresentation>) {
        switch change {
        case .title(_):
            self.setTitle(_viewModel.getTitle())
        case .loading(let isVisible):
            isVisible ? self.showFullSizeLoading() : self.hideFullSizeLoading()
            
        case .footerViewLoading(let isVisible):
            _listView.updateFooterViewVisibility(isVisible: isVisible)
        case .presentations(let itemPresentations):
            _listView.configure(with: itemPresentations)
        case .error(_):
            break
        case .fetchNewItemsEnabled(let isEnabled):
            _listView.fetchNewItemsEnabled(isEnabled: isEnabled)
        case .reloadItemsAtIndexes(_):
            break
        case .infoToast(_):
            break 
        case .pages(let currentPage, let totalPage):
            self.pageIndicatorView?.updateTitle(currentPage: currentPage, totalPage: totalPage)
        }
    }
}

// MARK: -
extension TopicListViewController {

}

// MARK: -
extension TopicListViewController {

}

// MARK: -
extension TopicListViewController {

}

// MARK: -
extension TopicListViewController {

}

// MARK: -
extension TopicListViewController {

}

// MARK: -
extension TopicListViewController {

}

