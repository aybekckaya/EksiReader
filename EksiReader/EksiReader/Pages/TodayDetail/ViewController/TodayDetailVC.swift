//
//  File.swift
//  EksiReader
//
//  Created by aybek can kaya on 12.04.2022.
//

import Foundation
import UIKit

class TodayDetailVC: ERViewController {
    private let viewModel: TodayDetailViewModel
    private let listView: ERListView<TopicCell, TopicEntryPresentation> = .init()

    init(viewModel: TodayDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle
extension TodayDetailVC {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var _viewModel = viewModel
        _viewModel.loadNewItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()

    }
}

// MARK: - Set Up UI
extension TodayDetailVC {
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
                NSLog("Selected: \(presentation)")
            }
    }
}


// MARK: - Listeners
extension TodayDetailVC {
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
            case .presentations(let itemPresentations):
                self.listView.configure(with: itemPresentations)
            }
        }
    }
}
