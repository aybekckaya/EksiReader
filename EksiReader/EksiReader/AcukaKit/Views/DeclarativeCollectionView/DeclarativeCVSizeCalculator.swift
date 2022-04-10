//
//  DeclarativeCVSizeCalculator.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 26.03.2022.
//

import Foundation
import UIKit

// MARK: - DeclarativeCLSizeCalculatorModel
 struct DeclarativeCLSizeCalculatorModel {
    let collectionViewSize: CGSize
    var itemSize: DeclarativeCollectionViewItemSize
    let layout: DeclarativeCollectionViewLayout
}

// MARK: - DeclarativeCLSizeCalculator
 protocol DeclarativeCLSizeCalculator {
    init(model: DeclarativeCLSizeCalculatorModel)
    func calculate() -> CGSize
}

// MARK: - DeclarativeCollectionSizeRatioCalculator
final class DeclarativeCollectionSizeRatioCalculator: DeclarativeCLSizeCalculator {
    private let calculatorModel: DeclarativeCLSizeCalculatorModel

    init(model: DeclarativeCLSizeCalculatorModel) {
        self.calculatorModel = model
    }

    func calculate() -> CGSize {
        validate()
        // if case .success(let data) = result { ... }
        guard
            case DeclarativeCollectionViewItemSize.dynamicSizeRatio(let numberOfColumns, let numberOfRows, let ratio) = calculatorModel.itemSize
        else {
            return .zero
        }

        var calculatorModelNew = self.calculatorModel
        calculatorModelNew.itemSize = .dynamicSize(numberOfColumns: numberOfColumns, numberOfRows: numberOfRows)
        let calculator = DeclarativeCollectionDynamicSizeCalculator(model: calculatorModelNew)
        let size = calculator.calculate()

        switch calculatorModel.layout.axis {
        case .vertical(_):
            let width = size.width
            let height = size.width * ratio
            return .init(width: width, height: height)

        case .horizontal(_):
            let height = size.height
            let width = height * ratio
            return .init(width: width, height: height)
        }
    }

    private func validate() {
        let validator = DeclarativeSizeCalculatorValidator(model: calculatorModel)
        validator.validate()
    }

}

// MARK: - DeclarativeCollectionDynamicSizeCalculator
final class DeclarativeCollectionDynamicSizeCalculator: DeclarativeCLSizeCalculator {
    private let calculatorModel: DeclarativeCLSizeCalculatorModel

    init(model: DeclarativeCLSizeCalculatorModel) {
        self.calculatorModel = model
    }

    func calculate() -> CGSize {
        validate()
        switch calculatorModel.layout.axis {
        case .vertical(let height):
            return verticalSize(height: height)
        case .horizontal(let width):
            return horizontalSize(width: width)
        }
    }

    private func verticalSize(height: CGFloat?) -> CGSize {
        switch calculatorModel.itemSize {
        case .staticSize(_, _), .dynamicSizeRatio(_, _, _):
            return .zero
        case .dynamicSize(let numberOfColumns, _):
            guard
                let numberOfColumns = numberOfColumns,
                let height = height
            else {
                return .zero
            }

            let spaces = calculatorModel.layout.collectionViewInsets.left
            + calculatorModel.layout.collectionViewInsets.right
            + CGFloat(numberOfColumns - 1) * calculatorModel.layout.horizontalSpacing
            let widthNoSpace = calculatorModel.collectionViewSize.width - spaces
            let itemWidth = widthNoSpace / CGFloat(numberOfColumns)

            return .init(width: itemWidth - 1, height: height)
        }
    }

    private func horizontalSize(width: CGFloat?) -> CGSize {
        switch calculatorModel.itemSize {
        case .staticSize(_, _), .dynamicSizeRatio(_, _, _):
            return .zero
        case .dynamicSize(_, let numberOfRows):
            guard
                let numberOfRows = numberOfRows,
                let width = width
            else {
                return .zero
            }

            let spaces = calculatorModel.layout.collectionViewInsets.top
            + calculatorModel.layout.collectionViewInsets.bottom
            + CGFloat(numberOfRows - 1) * calculatorModel.layout.verticalSpacing
            let heightNoSpace = calculatorModel.collectionViewSize.height - spaces
            let itemHeight = heightNoSpace / CGFloat(numberOfRows)

            return .init(width: width, height: itemHeight - 1)
        }
    }

    private func validate() {
        let validator = DeclarativeSizeCalculatorValidator(model: calculatorModel)
        validator.validate()
    }

}

// MARK: - Calculator Validator
final fileprivate class DeclarativeSizeCalculatorValidator {
    private let calculatorModel: DeclarativeCLSizeCalculatorModel

    init(model: DeclarativeCLSizeCalculatorModel) {
        self.calculatorModel = model
    }

    func validate() {
        switch calculatorModel.layout.axis {
        case .vertical(let height):
            verticalValidation(height: height)
        case .horizontal(let width):
            horizontalValidation(width: width)
        }
    }

    private func verticalValidation(height: CGFloat?) {
        guard
            let _ = height
        else {
            fatalError("Height Should Not Be Nil")
        }
        switch calculatorModel.itemSize {
        case .staticSize(_, _):
            break
        case .dynamicSize(let numberOfColumns, let numberOfRows):
            if numberOfRows != nil && numberOfColumns != nil {
                fatalError("both row count and column count should not be specified")
            } else if numberOfColumns == nil {
                fatalError("column count should not be nil")
            }
        case .dynamicSizeRatio(let numberOfColumns, let numberOfRows, _):
            if numberOfRows != nil && numberOfColumns != nil {
                fatalError("both row count and column count should not be specified")
            } else if numberOfColumns == nil {
                fatalError("column count should not be nil")
            }
        }
    }

    private func horizontalValidation(width: CGFloat?) {
        guard
            let _ = width
        else {
            fatalError("Width Should Not Be Nil")
        }
        switch calculatorModel.itemSize {
        case .staticSize(_, _):
            break
        case .dynamicSize(let numberOfColumns, let numberOfRows):
            if numberOfRows != nil && numberOfColumns != nil {
                fatalError("both row count and column count should not be specified")
            } else if numberOfRows == nil {
                fatalError("row count should not be nil")
            }
        case .dynamicSizeRatio(let numberOfColumns, let numberOfRows, _):
            if numberOfRows != nil && numberOfColumns != nil {
                fatalError("both row count and column count should not be specified")
            } else if numberOfRows == nil {
                fatalError("row count should not be nil")
            }
        }
    }
}

