//
//  File.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit
import Loaf

class TopicViewController: ERViewController {
    private let viewModel: TopicViewModel
    private let listView: ERListView<TopicCell, TopicItemPresentation> = .init()

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
        addListeners()

        var _viewModel = viewModel
        _viewModel.loadNewItems()
    }
}

// MARK: - Set Up UI
extension TopicViewController {
    private func setUpUI() {
        listView
            .add(into: self.view)
            .fit()

        listView
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
                self.title = title
               
            case .fetchNewItemsEnabled(let isEnabled):
                self.listView.fetchNewItemsEnabled(isEnabled: isEnabled)
            case .error(let error):
                break
            case .footerViewLoading(let isVisible):
                self.listView.updateFooterViewVisibility(isVisible: isVisible)
            case .loading(let isVisible):
                isVisible ? EksiLoadingView.show() : EksiLoadingView.hide()
               // break
            case .presentations(let _):

                let updatedPresentations = self.viewModel.updatedPresentations()
                self.listView.configure(with: updatedPresentations)
            case .reloadItemsAtIndexes(let indexes):
                break
            case .infoToast( let message):
                self.showToast(message: message)
            }
        }
    }
}
