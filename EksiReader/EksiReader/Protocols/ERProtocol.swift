//
//  ERProtocol.swift
//  EksiReader
//
//  Created by aybek can kaya on 13.04.2022.
//

import Foundation
import UIKit


// MARK: - ERListCell
protocol ERListCell: AnyObject where Self: UITableViewCell {
    associatedtype T
    func configure(with item: T) 
}

// MARK: - ERBaseResponse
protocol ERBaseResponse where Self: Decodable {
    var success: Bool? { get set }
    var message: String? {get set}
}

// MARK: - ERPagable
protocol ERPagable {
    associatedtype T
    var pageCount: Int { get set }
    var pageIndex: Int { get set }
    var entries: [T] { get set }
}

protocol ERResponseTitle {
    var title: String? { get set }
}

// MARK: - Pagable Presentation
protocol PagablePresentation {
    associatedtype PresentationEntry
    init(entry: PresentationEntry)
}

extension String {
    func attributedTodayTitle() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Styling.TodaysCell.titleLineSpacing
        paragraphStyle.lineHeightMultiple = 1

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        return attributedString
    }

    func attributedTopicContent(links: [String]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Styling.TodaysCell.titleLineSpacing
        paragraphStyle.lineHeightMultiple = 1.2

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))

        let string = NSString(string: self)
        links.forEach { str in
            let range = string.range(of: str)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: range)
            attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.white, range: range)
        }

        return attributedString
    }
}


// MARK: - PagableViewModel
enum PagableViewModelChange<P> {
    case title(title: String?)
    case loading(isVisible: Bool)
    case footerViewLoading(isVisible: Bool)
    case presentations(itemPresentations: [P])
    case error(error: EksiError)
    case fetchNewItemsEnabled(isEnabled: Bool)
    case reloadItemsAtIndexes(indexes: [Int])
    case infoToast(message: String)
}

typealias PagableViewModelChangeCallback<T> = (T) -> Void
protocol PagableViewModel {
    associatedtype DataController: PagableDataController
    associatedtype Router
    associatedtype Presentation: PagablePresentation
    associatedtype Entry

    var dataController: DataController { get set }
    var router: Router { get set }
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<Presentation>>? { get set }
    var currentPresentations: [Presentation] { get set }

    init(dataController: DataController,
         router: Router)

    mutating func bind(_ callback: @escaping PagableViewModelChangeCallback<PagableViewModelChange<Presentation>>)
    mutating func resetEntries()
    mutating func loadNewItems()
    func trigger(_ change: PagableViewModelChange<Presentation>)
}

extension PagableViewModel {

    mutating func bind(_ callback: @escaping PagableViewModelChangeCallback<PagableViewModelChange<Presentation>>) {
        self.changeHandler = callback
    }

    mutating func resetEntries() {
        var _dataController = dataController
        _dataController.reset()
    }

    mutating func loadNewItems() {
        updateTitle()
        updateFooterLoadingViewVisibility()
        updateLoadingViewVisiblity(forcedVisiblity: nil)
        var _dataController = dataController
        var _self = self
        _dataController.loadNewItems { currentEntries, newEntries, error in
            let _currentEntries = (currentEntries as? [Entry]) ?? []
            let _newEntries = (newEntries as? [Entry]) ?? []
            _self.handleData(currentEntries: _currentEntries, newEntries: _newEntries, error: error)
            _self.updateLoadingViewVisiblity(forcedVisiblity: nil)
            _self.updateTitle()
        }
    }

    private mutating func handleData(currentEntries: [Entry], newEntries: [Entry], error: EksiError?) {
        let newPresentations: [Presentation] = newEntries.compactMap {
            guard let presentationEntry = $0 as? Presentation.PresentationEntry else { return nil }
            return Presentation.init(entry: presentationEntry)
        }
        currentPresentations.append(contentsOf: newPresentations)
        trigger(.presentations(itemPresentations: currentPresentations))
        updateFooterLoadingViewVisibility()
    }

    private func updateFooterLoadingViewVisibility() {
        guard !currentPresentations.isEmpty else {
            trigger(.footerViewLoading(isVisible: false))
            trigger(.fetchNewItemsEnabled(isEnabled: true))
            return
        }
        let canLoadNewItems = dataController.canLoadNewItems()
        if canLoadNewItems {
            trigger(.footerViewLoading(isVisible: true))
            trigger(.fetchNewItemsEnabled(isEnabled: true))
        } else {
            trigger(.footerViewLoading(isVisible: false))
            trigger(.fetchNewItemsEnabled(isEnabled: false))
        }
    }

    private func updateLoadingViewVisiblity(forcedVisiblity: Bool? = nil) {
        if let forcedVisiblity = forcedVisiblity {
            trigger(.loading(isVisible: forcedVisiblity))
            return
        }
        guard currentPresentations.isEmpty else {
            trigger(.loading(isVisible: false))
            return
        }
        trigger(.loading(isVisible: true))
    }

    private func updateTitle() {
        if let response = dataController.response as? ERResponseTitle {
            trigger(.title(title: response.title))
            return
        }
        trigger(.title(title: nil))
    }

     func trigger(_ change: PagableViewModelChange<Presentation>) {
        DispatchQueue.main.async {
            self.changeHandler?(change)
        }
    }
}
