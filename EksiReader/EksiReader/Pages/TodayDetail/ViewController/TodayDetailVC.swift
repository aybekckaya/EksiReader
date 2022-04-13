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
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
        var _viewModel = viewModel
        _viewModel.loadNewItems()
    }
}

// MARK: - Set Up UI
extension TodayDetailVC {
    private func setUpUI() {

    }
}


// MARK: - Listeners
extension TodayDetailVC {
    private func addListeners() {
        var _viewModel = viewModel
        _viewModel.bind { change in
            switch change {
            case .fetchNewItemsEnabled(let isEnabled):
                break
            case .error(let error):
                break
            case .footerViewLoading(let isVisible):
                break
            case .loading(let isVisible):
                break
            case .presentations(let itemPresentations):
                NSLog("\(itemPresentations)")
                break
            }
        }
    }
}
