//
//  ERDataControllerProtocols.swift
//  EksiReader
//
//  Created by aybek can kaya on 17.04.2022.
//

import Foundation

enum ERListSortType {
    case firstToLast
    case lastToFirst
}

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
typealias PagableDataControllerCloudCallback<T> = ([T], [T], EksiError?, Int, Int) -> Void

protocol PagableDataController {
    associatedtype T: Decodable
    associatedtype Response: ERBaseResponse & ERPagable

    var entries: [T] { get set }
    var currentPageIndex: Int { get set }
    var finalPageIndex: Int { get set }
    var totalPages: Int { get set }
    var endpoint: EREndpoint? { get }
    var response: Response? { get set }
    var sortingType: ERListSortType { get }

    mutating func reset()
    func canLoadNewItems() -> Bool
    func currentVisiblePage(from visiblePageIndexes: [Int]) -> Int
    mutating func loadNewItems(_ callback: @escaping PagableDataControllerCallback<T>)
}

extension PagableDataController {
    func currentVisiblePage(from visiblePageIndexes: [Int]) -> Int  {
        guard visiblePageIndexes.count > 0 else { return 1 }
        var sum: Int = 0
        visiblePageIndexes.forEach { sum += $0 }
        return Int(sum / visiblePageIndexes.count)
    }

    mutating func reset() {
        entries = []
        switch sortingType {
        case .firstToLast:
            currentPageIndex = 0
            finalPageIndex = Int.max
        case .lastToFirst:
            currentPageIndex = Int.max
            finalPageIndex = 0
        }
    }

    func canLoadNewItems() -> Bool {
        switch sortingType {
        case .firstToLast:
            return currentPageIndex + 1 < finalPageIndex
        case .lastToFirst:
            return currentPageIndex - 1 > 0
        }
    }

    func iterateToNextPage() {
        var _self = self
        if _self.shouldMakePagingRequest() {
            return
        }
        switch sortingType {
        case .firstToLast:
            _self.currentPageIndex += 1
        case .lastToFirst:
            _self.currentPageIndex -= 1
        }
    }

    private func shouldMakePagingRequest() -> Bool {
        if sortingType == .firstToLast { return false }
        return self.currentPageIndex == Int.max
    }

    mutating private func addNewEntries(_ newEntries: [T]) {
        if sortingType == .firstToLast {
            entries.append(contentsOf: newEntries)
        } else if sortingType == .lastToFirst {
            let reversedNewEntries = newEntries.reversed()
            reversedNewEntries.forEach {
                entries.insert($0, at: 0)
            }
        }
    }

    mutating func loadNewItems(_ callback: @escaping PagableDataControllerCallback<T>) {
        var _self = self
        guard canLoadNewItems() else {
            callback(entries, [], nil)
            return
        }

        iterateToNextPage()

        if shouldMakePagingRequest() {
            _callCloud(endpoint: _self.endpoint) { _, _, _, _currentPage, _totalPage in
                _self.totalPages = _totalPage
                _self.currentPageIndex = _self.sortingType == .firstToLast ? _currentPage : _totalPage
                _self.finalPageIndex = _self.sortingType == .firstToLast ? _totalPage : _currentPage

                _self._callCloud(endpoint: _self.endpoint) { currEntries, newEntries, error, currPage, totalPage in
                    _self.totalPages = _totalPage
                    _self.currentPageIndex = _self.sortingType == .firstToLast ? currPage : totalPage
                    _self.finalPageIndex = _self.sortingType == .firstToLast ? totalPage : currPage
                    if currPage == totalPage {
                        _self.finalPageIndex = 1
                    }
                    _self.addNewEntries(newEntries)
                    callback(currEntries, newEntries, error)
                }
            }
        } else {
            _callCloud(endpoint: _self.endpoint) { currEntries, newEntries, error, currPage, totalPage in
                _self.totalPages = totalPage
                _self.currentPageIndex = currPage
                _self.finalPageIndex = _self.sortingType == .firstToLast ? totalPage : 1
                _self.addNewEntries(newEntries)
                callback(currEntries, newEntries, error)
            }
        }
    }

    mutating private func _callCloud(endpoint: EREndpoint?,
                             _ callback: @escaping PagableDataControllerCloudCallback<T>) {
        var _self = self
        guard let endpoint = _self.endpoint else {
            callback(entries, [], nil, currentPageIndex, finalPageIndex)
            return
        }
        EksiCloud.shared
            .call(endpoint: endpoint, responseType: Response.self) { response in
                _self.response = response
                let parser: PagableDataControllerParser<Response, T> = .init(response: response,
                                                                             currentEntries: _self.entries)
                parser.parse { currentEntries, newEntries, error, pageIndex, pageCount in
                    callback(_self.entries, newEntries, error, pageIndex, pageCount)
                }
            }
    }
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

