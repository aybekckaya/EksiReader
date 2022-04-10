//
//  ScrollableView.swift
//  UIElementsApp
//
//  Created by aybek can kaya on 10.03.2022.
//

import Foundation
import UIKit

enum ScrollableViewAxis {
    case horizontal
    case vertical

    var stackViewAxis: NSLayoutConstraint.Axis {
        switch self {
        case .vertical:
            return .vertical
        case .horizontal:
            return .horizontal
        }
    }
}


typealias ScrollableViewContentOffsetClosure = (ScrollableView, CGPoint) -> ()

class ScrollableView: UIView {
    private let axis: ScrollableViewAxis

    private var _scrollView: UIScrollView?
    private var _stackView: UIStackView?
    private var contentOffsetClosure: ScrollableViewContentOffsetClosure?

    var scrollView: UIScrollView { _scrollView! }
    var stackView: UIStackView { _stackView! }

    fileprivate init(axis: ScrollableViewAxis) {
        self.axis = axis
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Set Up UI
extension ScrollableView {
    private func setUpUI() {
        translatesAutoresizingMaskIntoConstraints = false

        let scrollView = UIScrollView
            .scrollView()
            .add(into: self)
            .fit()
            .asScrollView()

        self._scrollView = scrollView
        self._scrollView?.delegate = self

        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 0, axis: axis.stackViewAxis)
            .add(into: scrollView)
            .fit()
            .asStackView()

        self._stackView = stackView

        if axis == .vertical {
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0).isActive = true
        } else if axis == .horizontal {
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: 0).isActive = true
        }
    }
}

// MARK: - ScrollView Delegate
extension ScrollableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard
            let contentOffsetClosure = contentOffsetClosure
        else {
            return
        }
        contentOffsetClosure(self, scrollView.contentOffset)
    }
}


// MARK: - Public
extension ScrollableView {
    func insertViews(_ views: [UIView]) {
        views.forEach { insert($0) }
    }

    func insert(_ view: UIView) {
        guard let stackView = _stackView else { return }
        stackView.addArrangedSubview(view)
    }

    func show(_ view: UIView, isAnimated: Bool) {
        guard let stackView = _stackView else { return }
        let arrangedView = stackView.arrangedSubviews.first { $0 === view }
        guard let arrangedView = arrangedView else { return }

        if isAnimated == false {
            arrangedView.isHidden = false
            return
        }

        Anima
            .animate(with: .uiKitSpring(duration: 1.0,
                                        options: .allowUserInteraction,
                                        damping: 0.8,
                                        initialVelocity: 0.5)) {
                arrangedView.isHidden = false
            }.start()
    }

    func hide(_ view: UIView, isAnimated: Bool) {
        guard let stackView = _stackView else { return }
        let arrangedView = stackView.arrangedSubviews.first { $0 === view }
        guard let arrangedView = arrangedView else { return }

        if isAnimated == false {
            arrangedView.isHidden = true
            return
        }

        Anima
            .animate(with: .uiKitSpring(duration: 1.0,
                                        options: .allowUserInteraction,
                                        damping: 0.8,
                                        initialVelocity: 0.5)) {
                arrangedView.isHidden = true
            }.start()
    }

    @discardableResult
    func contentOffset(_ closure: @escaping ScrollableViewContentOffsetClosure) -> ScrollableView {
        self.contentOffsetClosure = closure
        return self
    }
}

// MARK: - Declarative UI
extension ScrollableView {
    static func scrollableView(axis: ScrollableViewAxis) -> ScrollableView {
        let view = ScrollableView(axis: axis)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asScrollableView() -> ScrollableView {
        return self as! ScrollableView
    }
}
