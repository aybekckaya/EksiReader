//
//  DeclarativeTableView.swift
//  PodnaTrainer
//
//  Created by aybek can kaya on 12.10.2021.
//

import Foundation
import UIKit

protocol DeclarativeListItem {}

class DeclarativeTableView<T: UITableViewCell, G: DeclarativeListItem>: UITableView, UITableViewDelegate, UITableViewDataSource {

    private var items: [G] = []

    private var cellForRowClosure: ((DeclarativeTableView, T, G, IndexPath) -> Void)?
    private var cellHeightClosure: ((DeclarativeTableView, G, IndexPath) -> CGFloat)?
    private var cellDidSelectClosure: ((DeclarativeTableView, G, IndexPath) -> Void)?
    private var willDisplayCellClosure: ((DeclarativeTableView, T, G, IndexPath) -> Void)?
    private var willDisplayLastCellClosure: ((DeclarativeTableView, T, G, IndexPath) -> Void)?
    private var didEndDisplayCellClosure: ((DeclarativeTableView, T, G, IndexPath) -> Void)?
    private var footerViewClosure: (() -> UIView?)?

    init() {
        super.init(frame: .zero, style: .plain)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Delegate/Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let closure = cellForRowClosure else { fatalError("Implement cell for row closure") }
        let cell: T = tableView.deque(indexPath: indexPath)
        let model = items[indexPath.row]
        cell.onTap { _ in
            guard let closure = self.cellDidSelectClosure else { return }
            let model = self.items[indexPath.row]
            closure(self, model, indexPath)
        }

        closure(self, cell, model, indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
        guard let closure = cellHeightClosure else { return UITableView.automaticDimension }
        let model = items[indexPath.row]

        return closure(self, model, indexPath)
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let closure = cellDidSelectClosure else { return }
        let model = items[indexPath.row]
        closure(self, model, indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        callWillDisplayCellClosure(cell: cell, indexPath: indexPath)
        callFooterViewClosure(indexPath: indexPath)
        callWillDisplayLastCellClosure(cell: cell, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard
            let didEndDisplayCellClosure = didEndDisplayCellClosure,
            let currentCell: T = cell as? T
        else {
            return
        }
        let model = items[indexPath.row]
        didEndDisplayCellClosure(self, currentCell, model, indexPath)
    }
}

// MARK: - Delegate / Datasource helpers
extension DeclarativeTableView {
    private func callWillDisplayLastCellClosure(cell: UITableViewCell, indexPath: IndexPath) {
        guard
            let willDisplayLastCellClosure = willDisplayLastCellClosure,
            let currentCell: T = cell as? T,
            indexPath.row >= items.count - 1
        else {
            return
        }

        let model = items[indexPath.row]
        willDisplayLastCellClosure(self, currentCell, model, indexPath)
    }

    private func callWillDisplayCellClosure(cell: UITableViewCell, indexPath: IndexPath) {
        guard
            let willDisplayCellClosure = willDisplayCellClosure,
            let currentCell: T = cell as? T
        else {
            return
        }

        let model = items[indexPath.row]
        willDisplayCellClosure(self, currentCell, model, indexPath)
    }

    private func callFooterViewClosure(indexPath: IndexPath) {
        guard
            items.count > 0,
            indexPath.row >= items.count - 1,
            let footerViewClosure = footerViewClosure
        else {
            return
        }
        self.tableFooterView = footerViewClosure()
    }
}

// MARK: - Set Up UI
extension DeclarativeTableView {
    private func setUpUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.registerCell(T.self, identifier: T.identifier)
        self.delegate = self
        self.dataSource = self
        self.reload()
    }
}

// MARK: - Public
extension DeclarativeTableView {
    func updateItems(_ items: [G]) {
        self.items = items
        DispatchQueue.main.async {
            self.reload()
            self.layoutIfNeeded()
        }
    }

    @discardableResult
    func willDisplayLastCell(_ closure: ((DeclarativeTableView, T, G, IndexPath) -> Void)?) -> DeclarativeTableView {
        self.willDisplayLastCellClosure = closure
        return self
    }

    @discardableResult
    func footerView(_ closure: @escaping (() -> UIView?)) -> DeclarativeTableView {
        self.footerViewClosure = closure
        return self
    }

    @discardableResult
    func hideFooterView() -> DeclarativeTableView  {
        self.tableFooterView = nil
        return self
    }

    @discardableResult
    func cellAtIndex(_ closure: ((DeclarativeTableView, T, G, IndexPath) -> Void)?) -> DeclarativeTableView {
        self.cellForRowClosure = closure
        return self
    }

    @discardableResult
    func height(_ closure: ((DeclarativeTableView, G, IndexPath) -> CGFloat)?) -> DeclarativeTableView {
        self.cellHeightClosure = closure
        return self
    }

    @discardableResult
    func didSelectCell(_ closure: ((DeclarativeTableView, G, IndexPath) -> Void)?) -> DeclarativeTableView {
        self.cellDidSelectClosure = closure
        return self
    }

    @discardableResult
    func willDisplayCell(_ closure:  ((DeclarativeTableView, T, G, IndexPath) -> Void)?) -> DeclarativeTableView {
        self.willDisplayCellClosure = closure
        return self
    }

    @discardableResult
    func didEndDisplayCell(_ closure:  ((DeclarativeTableView, T, G, IndexPath) -> Void)?) -> DeclarativeTableView {
        self.didEndDisplayCellClosure = closure
        return self
    }

}

// MARK: - Declarative UI
extension DeclarativeTableView {
    static func declarativeTableView<T: UITableViewCell, G: DeclarativeListItem>() -> DeclarativeTableView<T, G> {
        let table = DeclarativeTableView<T, G>()
        return table
    }
}

extension UIView {
    func asDeclarativeTableView<T: UITableViewCell, G: DeclarativeListItem>() -> DeclarativeTableView<T, G> {
        return self as! DeclarativeTableView<T, G>
    }
}
