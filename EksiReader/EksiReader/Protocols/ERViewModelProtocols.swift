//
//  ERViewModelProtocols.swift
//  EksiReader
//
//  Created by aybek can kaya on 18.04.2022.
//

import Foundation

typealias PagableViewModelChangeCallback<T> = (T) -> Void

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
    case pages(currentPage: Int, totalPage: Int)
}

// MARK:- Pagable View Model
protocol PagableViewModel: AnyObject {
    associatedtype DataController: PagableDataController
    associatedtype Router
    associatedtype Presentation: PagablePresentation

    typealias Entry = DataController.T

    var dataController: DataController { get set }
    var router: Router { get set }
    var changeHandler: PagableViewModelChangeCallback<PagableViewModelChange<Presentation>>? { get set }
    var currentPresentations: [Presentation] { get set }

    var listSortingType: ERListSortType { get }

    init(dataController: DataController,
         router: Router)

     func bind(_ callback: @escaping PagableViewModelChangeCallback<PagableViewModelChange<Presentation>>)
     func resetEntries()
     func loadNewItems()
    func visiblePresentations(_ presentations: [Presentation])
    func trigger(_ change: PagableViewModelChange<Presentation>)
    func reloadPresentations()
}

extension PagableViewModel {
    func reloadPresentations() {

    }

    func visiblePresentations(_ presentations: [Presentation]) {
        let presentationPageIndexes: [Int] = presentations.map { $0.page }
        let currentVisiblePageIndex = dataController.currentVisiblePage(from: presentationPageIndexes)
        trigger(.pages(currentPage: currentVisiblePageIndex, totalPage: dataController.totalPages))
    }

     func bind(_ callback: @escaping PagableViewModelChangeCallback<PagableViewModelChange<Presentation>>) {
        self.changeHandler = callback
    }

     func resetEntries() {
        var _dataController = dataController
        _dataController.reset()
        currentPresentations = []
    }

     func loadNewItems() {
        updateTitle()
        updateFooterLoadingViewVisibility()
        updateLoadingViewVisiblity(forcedVisiblity: nil)
        var _dataController = dataController
        _dataController.loadNewItems { [weak self] currentEntries, newEntries, error in
            guard let _self = self else { return }
            let _currentEntries = (currentEntries as [Entry]) 
            let _newEntries = (newEntries as [Entry])
            _self.handleData(currentEntries: _currentEntries,
                             newEntries: _newEntries,
                             error: error,
                             entryPage: _dataController.currentPageIndex)
            _self.updateLoadingViewVisiblity(forcedVisiblity: nil)
            _self.updateTitle()
        }
    }

    private  func handleData(currentEntries: [Entry],
                                     newEntries: [Entry],
                                     error: EksiError?,
                                     entryPage: Int) {
        let newPresentations: [Presentation] = newEntries.compactMap {
            guard let presentationEntry = $0 as? Presentation.PresentationEntry else { return nil }
            return Presentation.init(entry: presentationEntry, entryPage: entryPage)
        }

        let dateSortedItems = dateSortedPresentations(from: newPresentations)
        let followStatusUpdatedItems = setFollowingStatuses(dateSortedItems)
        if followStatusUpdatedItems.isEmpty {
            currentPresentations.append(contentsOf: dateSortedItems)
        } else {
            currentPresentations.append(contentsOf: followStatusUpdatedItems)
        }

        trigger(.presentations(itemPresentations: currentPresentations))
        updateFooterLoadingViewVisibility()
    }

    private func setFollowingStatuses(_ presentations: [Presentation]) -> [Presentation] {
        let storage = APP.storage
        var newPresentations: [TopicListItemPresentation] = []
        presentations.forEach {
            if var listPresentation = $0 as? TopicListItemPresentation {
                let isFollowing = storage.isEntryFollowing(entryId: listPresentation.id)
                listPresentation.setIsFollowing(isFollowing)
                newPresentations.append(listPresentation)
            }
        }
        return newPresentations.compactMap { $0 as? Presentation }
    }

    private func dateSortedPresentations(from presentations: [Presentation]) -> [Presentation] {
        let dateablePresentations = presentations
            .compactMap { $0 as? DateablePresentation }

        if dateablePresentations.isEmpty {
            return presentations
        }

        switch self.listSortingType {
        case .firstToLast:
            return dateablePresentations
                .sorted { prs1, prs2 in
                    let date1 = prs1.createdDateValue ?? Date(timeIntervalSince1970: 0)
                    let date2 = prs2.createdDateValue ?? Date(timeIntervalSince1970: 0)
                    return date1 < date2
                }.compactMap {
                    return $0 as? Presentation
                }
        case .lastToFirst:
            return dateablePresentations
                .sorted { prs1, prs2 in
                    let date1 = prs1.createdDateValue ?? Date(timeIntervalSince1970: 0)
                    let date2 = prs2.createdDateValue ?? Date(timeIntervalSince1970: 0)
                    return date1 > date2
                }.compactMap {
                    return $0 as? Presentation
                }
        }
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
        guard let _ = dataController.endpoint else {
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
