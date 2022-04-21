//
//  ERViewModelProtocols.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation


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

    typealias Entry = DataController.T

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