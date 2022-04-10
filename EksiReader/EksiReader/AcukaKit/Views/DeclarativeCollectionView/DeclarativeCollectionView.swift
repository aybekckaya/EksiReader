//
//  DeclarativeCollectionView.swift
//  PodnaTrainer
//
//  Created by aybek can kaya on 12.10.2021.
//

import Foundation
import UIKit

/*
// MARK: - TODO:
 4 lü , 3 lü item gruplama
 Automatic cell resize
 Custom Layout

*/

// MARK: - DeclarativeCollectionViewAxis
enum DeclarativeCollectionViewAxis {
    case vertical(height: CGFloat?)
    case horizontal(width: CGFloat?)

    var collectionViewAxis: UICollectionView.ScrollDirection {
        switch self {
        case .vertical(_):
            return .vertical
        case .horizontal(_):
            return .horizontal
        }
    }
}

// MARK: - DeclarativeCollectionViewItemSize
enum DeclarativeCollectionViewItemSize {
    case staticSize(width: CGFloat, height: CGFloat)
    case dynamicSize(numberOfColumns: Int?, numberOfRows: Int?)
    case dynamicSizeRatio(numberOfColumns: Int?, numberOfRows: Int?, ratio: CGFloat)
}

// MARK: - DeclarativeCollectionViewLayout
struct DeclarativeCollectionViewLayout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let collectionViewInsets: UIEdgeInsets
    let axis: DeclarativeCollectionViewAxis
}


// MARK: - DeclarativeCollectionView
class DeclarativeCollectionView<T: UICollectionViewCell, G: DeclarativeListItem>:UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var declarativeLayout: DeclarativeCollectionViewLayout?

    private var items: [G] = []
    private var cellForRowClosure: ((DeclarativeCollectionView, T, G, IndexPath) -> Void)?
    private var cellSizeClosure: ((DeclarativeCollectionView, G, IndexPath) -> DeclarativeCollectionViewItemSize)?
    private var cellDidSelectClosure: ((DeclarativeCollectionView, G, IndexPath) -> Void)?
    private var collectionViewContentSize: ((DeclarativeCollectionView, CGSize) -> Void)?
    private var collectionViewWillDisplayCellClosure: ((DeclarativeCollectionView, T, G, IndexPath) -> Void)?
    private var collectionViewDidEndDisplayCellClosure: ((DeclarativeCollectionView, T, G, IndexPath) -> Void)?

    fileprivate init(layout: DeclarativeCollectionViewLayout? = nil) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        updateLayout(layout, animated: false)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let closure = collectionViewContentSize {
            closure(self, contentSize)
        }
       // NSLog("Current Size Layout: \(frame), \(contentSize), \(bounds)")
    }

    // MARK: - CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let closure = cellForRowClosure else { fatalError("Implement cell for row closure") }
        let cell: T = collectionView.deque(indexPath: indexPath)
        let model = items[indexPath.row]
        closure(self, cell, model, indexPath)
        return cell
    }

    // MARK: - CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let closure = cellDidSelectClosure else { return }
        let model = items[indexPath.row]
        closure(self, model, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard
            let closure = cellSizeClosure,
            let layout = declarativeLayout
        else {
            return .init(width: 44, height: 44)
        }

        let model = items[indexPath.row]
        let sizeValue = closure(self, model, indexPath)

        return calculateSize(collectionViewSize: collectionView.frame.size, itemSize: sizeValue, layout: layout)
    }

    // collectionView ın sağından solundan üzerinden olan boşluklar
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard
            let declarativeLayout = declarativeLayout
        else {
            return .zero
        }
        return declarativeLayout.collectionViewInsets
    }

    // Dikey boşluk
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard
            let declarativeLayout = declarativeLayout
        else {
            return 0
        }
        return declarativeLayout.verticalSpacing
    }

    // Yatay boşluk
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard
            let declarativeLayout = declarativeLayout
        else {
            return 0
        }
        return declarativeLayout.horizontalSpacing
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewWillDisplayCellClosure = collectionViewWillDisplayCellClosure else {
            return
        }

        let model = items[indexPath.row]
        let cell: T = cell as! T
        collectionViewWillDisplayCellClosure(self, cell, model, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let collectionViewDidEndDisplayCellClosure = collectionViewDidEndDisplayCellClosure else {
            return
        }

        let model = items[indexPath.row]
        let cell: T = cell as! T
        collectionViewDidEndDisplayCellClosure(self, cell, model, indexPath)
    }
}

// MARK: - Size Calculator
extension DeclarativeCollectionView {
    private func calculateSize(collectionViewSize: CGSize,
                               itemSize: DeclarativeCollectionViewItemSize,
                               layout: DeclarativeCollectionViewLayout ) -> CGSize {

        let calculatorModel = DeclarativeCLSizeCalculatorModel(
            collectionViewSize: collectionViewSize,
            itemSize: itemSize,
            layout: layout)

        switch itemSize {
        case .staticSize(let width, let height):
            return .init(width: width, height: height)
        case .dynamicSize(_, _):
            let calculator = DeclarativeCollectionDynamicSizeCalculator(model: calculatorModel)
            return calculator.calculate()
        case .dynamicSizeRatio(_, _, _):
            let calculator = DeclarativeCollectionSizeRatioCalculator(model: calculatorModel)
            return calculator.calculate()
        }
    }
}

// MARK: - Set Up UI
extension DeclarativeCollectionView {
    private func setUpUI() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.registerCell(T.self, identifier: T.identifier)


        self.delegate = self
        self.dataSource = self
        self.reload()
    }
}

// MARK: - Public
extension DeclarativeCollectionView {
    func updateItems(_ items: [G]) {
        self.items = items
        self.reload()
    }

    @discardableResult
    func updateLayout(_ layout: DeclarativeCollectionViewLayout?, animated: Bool) -> DeclarativeCollectionView {
        guard let layout = layout else {
            return self
        }
        declarativeLayout = layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = layout.axis.collectionViewAxis
        setCollectionViewLayout(flowLayout, animated: animated) { _ in
            self.performBatchUpdates({
                let indexSet = IndexSet(integersIn: 0...0)
                self.reloadSections(indexSet)
            }, completion: nil)
            self.reloadData()
        }

        return self
    }

    @discardableResult
    func cellAtIndex(_ closure: ((DeclarativeCollectionView, T, G, IndexPath) -> Void)?) -> DeclarativeCollectionView {
        self.cellForRowClosure = closure
        return self
    }


    @discardableResult
    func didSelectCell(_ closure: ((DeclarativeCollectionView, G, IndexPath) -> Void)?) -> DeclarativeCollectionView {
        self.cellDidSelectClosure = closure
        return self
    }

    @discardableResult
    func size(_ closure: ((DeclarativeCollectionView, G, IndexPath) -> DeclarativeCollectionViewItemSize)?) -> DeclarativeCollectionView {
        self.cellSizeClosure = closure
        return self
    }

    @discardableResult
    func contentSize(_ closure: ((DeclarativeCollectionView, CGSize) -> Void)?) -> DeclarativeCollectionView {
        self.collectionViewContentSize = closure
        return self
    }

    @discardableResult
    func willDisplayCell(_ closure: ((DeclarativeCollectionView, T, G, IndexPath) -> Void)?) -> DeclarativeCollectionView {
        self.collectionViewWillDisplayCellClosure = closure
        return self
    }

    @discardableResult
    func didEndDisplayCell(_ closure: ((DeclarativeCollectionView, T, G, IndexPath) -> Void)?) -> DeclarativeCollectionView {
        self.collectionViewDidEndDisplayCellClosure = closure
        return self
    }
}

// MARK: - Declarative UI
extension DeclarativeCollectionView {
    static func declarativeCollectionView<T: UICollectionViewCell, G: DeclarativeListItem>(layout: DeclarativeCollectionViewLayout) -> DeclarativeCollectionView<T, G> {
        let table = DeclarativeCollectionView<T, G>(layout: layout)
        return table
    }

    static func declarativeCollectionView<T: UICollectionViewCell, G: DeclarativeListItem>() -> DeclarativeCollectionView<T, G> {
        let collection = DeclarativeCollectionView<T, G>()
        return collection
    }
}

extension UIView {
    func asDeclarativeCollectionView<T: UICollectionViewCell, G: DeclarativeListItem>() -> DeclarativeCollectionView<T, G> {
        return self as! DeclarativeCollectionView<T, G>
    }
}
