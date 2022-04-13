//
//  TodayViewModel.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation

typealias TodayViewModelChangeCallback = (TodayViewModel.Change) -> Void

class TodayViewModel {
    enum Change {
        case loading(isVisible: Bool)
        case footerViewLoading(isVisible: Bool)
        case presentations(itemPresentations: [TodayPresentation])
        case error(error: EksiError)
        case fetchNewItemsEnabled(isEnabled: Bool)
    }

    private let dataController: TodayDataController
    private let router: TodayRouter

    private var changeHandler: TodayViewModelChangeCallback?
    private var currentPresentations: [TodayPresentation] = []

    init(dataController: TodayDataController,
         router: TodayRouter) {
        self.dataController = dataController
        self.router = router
    }
}

// MARK: - Public
extension TodayViewModel {
    func selectItem(withIdentifier id: Int) {
        router.routeToDetail(topicId: id)
    }

    func bind(_ callback: @escaping TodayViewModelChangeCallback) {
        self.changeHandler = callback
    }

    func resetEntries() {
        var _dataController = dataController
        _dataController.reset()
    }

    func loadNewItems() {
        updateFooterLoadingViewVisibility()
        updateLoadingViewVisiblity(forcedVisiblity: nil)
        let handler = self.changeHandler
        var _dataController = dataController
        _dataController.loadNewItems { [weak self] currentEntries, newEntries, error in
            guard let self = self else {
                handler?(.error(error: .selfIsDeallocated))
                return
            }
            self.handleData(currentEntries: currentEntries, newEntries: newEntries, error: error)
            self.updateLoadingViewVisiblity(forcedVisiblity: nil)
        }
    }
}

// MARK: - Response Handler
extension TodayViewModel {
    private func handleData(currentEntries: [TodaysEntry], newEntries: [TodaysEntry], error: EksiError?) {
        let newPresentations: [TodayPresentation] = newEntries
            .compactMap {.init(entry: $0) }
        currentPresentations.append(contentsOf: newPresentations)
        trigger(.presentations(itemPresentations: currentPresentations))
        updateFooterLoadingViewVisibility()
    }
}


// MARK: - UI Manager
extension TodayViewModel {
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
}

// MARK: - Trigger Handler
extension TodayViewModel {
    private func trigger(_ change: Change) {
        DispatchQueue.main.async {
            self.changeHandler?(change)
        }
    }
}
