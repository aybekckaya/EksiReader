//
//  ERDataControllerProtocols.swift
//  EksiReader
//
//  Created by aybek can kaya on 17.04.2022.
//

import Foundation

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
