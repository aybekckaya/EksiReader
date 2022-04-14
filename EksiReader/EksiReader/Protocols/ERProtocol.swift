//
//  ERProtocol.swift
//  EksiReader
//
//  Created by aybek can kaya on 13.04.2022.
//

import Foundation
import UIKit

// MARK: - PagableDataControllerParser
// current_page, max_page
typealias PagableDataControllerParserCallback<T> = ([T], [T], EksiError?, Int, Int) -> Void

class PagableDataControllerParser<T: ERBaseResponse & ERPagable, E: Decodable> {
    private let response: T?
    private var currentEntries: [E]

    init(response: T?, currentEntries: [E]) {
        self.response = response
        self.currentEntries = currentEntries
    }

    func parse(_ callback: PagableDataControllerParserCallback<E>) {
        guard let response = response else {
            callback(currentEntries, [], .todaysResponseIsNil, -1, -1)
            return
        }

        if let message = response.message {
            NSLog("Show Error !!!")
            return
        }

        let newEntries = response.entries as? [E]
        currentEntries.append(contentsOf: newEntries ?? [])

        callback(currentEntries,
                 newEntries ?? [],
                 nil,
                 response.pageIndex,
                 response.pageCount)
    }
}

// MARK: - PagableDataController
// current_entries, new_entries, error
typealias PagableDataControllerCallback<T> = ([T], [T], EksiError?) -> Void

protocol PagableDataController {
    associatedtype T: Decodable
    associatedtype Response: ERBaseResponse & ERPagable

    var entries: [T] { get set }
    var currentPage: Int { get set }
    var totalPageCount: Int { get set }
    var endpoint: EREndpoint { get }
    var response: Response? { get set }

    mutating func reset()
    func canLoadNewItems() -> Bool
    mutating func loadNewItems(_ callback: @escaping PagableDataControllerCallback<T>)

//    func loadNewItems(_ callback: @escaping PagableDataControllerCallback<T>)
//    func handleResponse(response: Response, callback: @escaping PagableDataControllerCallback<T>)
}

extension PagableDataController {
    mutating func reset() {
        entries = []
        currentPage = 0
        totalPageCount = Int.max
    }

    func canLoadNewItems() -> Bool {
        return currentPage + 1 < totalPageCount
    }

    mutating func loadNewItems(_ callback: @escaping PagableDataControllerCallback<T>) {
        guard canLoadNewItems() else {
            callback(entries, [], nil)
            return
        }

        var _self = self
        _self.currentPage += 1 
        EksiCloud.shared
            .call(endpoint: endpoint, responseType: Response.self) { response in
                _self.response = response
                let parser: PagableDataControllerParser<Response, T> = .init(response: response, currentEntries: _self.entries)
                parser.parse { currentEntries, newEntries, error, pageIndex, pageCount in
                    _self.currentPage = pageIndex
                    _self.totalPageCount = pageCount
                    //_self.totalPageCount = 3
                    _self.entries.append(contentsOf: newEntries)
                    callback(_self.entries, newEntries, error)
                }
            }
    }
}

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

// MARK: - PagableViewModel
enum PagableViewModelChange<P> {
    case title(title: String?)
    case loading(isVisible: Bool)
    case footerViewLoading(isVisible: Bool)
    case presentations(itemPresentations: [P])
    case error(error: EksiError)
    case fetchNewItemsEnabled(isEnabled: Bool)
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
