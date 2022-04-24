//
//  ERViewProtocols.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation
import UIKit

// MARK: - ERBaseViewController
//protocol ERBaseViewController where Self: ERViewController {
//    func setTitle(_ title: String?)
//}

// MARK: - ERListCell
protocol ERListCell where Self: UITableViewCell {
    associatedtype T
    func configure(with item: T)
}

// MARK: - Pagable Presentation
protocol PagablePresentation {
    associatedtype PresentationEntry
    var page: Int { get }
    init(entry: PresentationEntry, entryPage: Int)
}

// MARK: - Dateable Presentation
protocol DateablePresentation {
    var createdDateValue: Date? { get }
}

// MARK: - Pagable View Controller
protocol PagableViewController where Self: ERViewController {
    associatedtype ViewModel: PagableViewModel
    associatedtype Cell: ERListCell
    associatedtype PresentationItem: PagableListItem

    var _viewModel: ViewModel { get }
    var showsPagingIndicatorView: Bool { get }
    var pageIndicatorView: ERPagingView? { get }
    var listView: ERListView<Cell, PresentationItem> { get }

    func initializePagableViewController()
}

extension PagableViewController {
    func initializePagableViewController() {
        if !showsPagingIndicatorView {
            if let pageIndicatorView = self.pageIndicatorView {
                pageIndicatorView.removeFromSuperview()
            }
            return
        }

        guard let pageIndicatorView = self.pageIndicatorView else { return }
        let height: CGFloat = 32
        pageIndicatorView
            .add(into: view)
            .leading(.constant(0))
            .trailing(.constant(0))
            .height(.constant(height))
            .top(.constant(self.navigationBarHeight + self.statusBarHeight))

        listView.setTopContentInset(height)
    }


}
