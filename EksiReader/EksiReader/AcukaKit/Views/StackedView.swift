//
//  StackedView.swift
//  PodnaMst2
//
//  Created by aybek can kaya on 16.03.2022.
//

import Foundation
import UIKit

class StackedView: UIView {
    private let stackView: UIStackView

    fileprivate init(alignment: UIStackView.Alignment,
         distribution: UIStackView.Distribution,
         spacing: CGFloat,
         axis: NSLayoutConstraint.Axis) {

        stackView = UIStackView
            .stackView(alignment: alignment, distribution: distribution, spacing: spacing, axis: axis)
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        stackView
            .add(into: self)
            .fit()

    }

    func insert(_ view: UIView, margin: UIEdgeInsets = .zero) {
        let containerView = UIView
            .view()
            .backgroundColor(.clear)

        containerView.addSubview(view)

        view
            .leading(.constant(margin.left))
            .trailing(.constant(margin.right))
            .top(.constant(margin.top))
            .bottom(.constant(margin.bottom))

        stackView.addArrangedSubview(containerView)
    }
}

extension StackedView {
    static func stackedView(alignment: UIStackView.Alignment,
                            distribution: UIStackView.Distribution,
                            spacing: CGFloat,
                            axis: NSLayoutConstraint.Axis) -> StackedView {
        let view = StackedView(alignment: alignment, distribution: distribution, spacing: spacing, axis: axis)
        return view
    }
}

extension UIView {
    func asStackedView() -> StackedView {
        return self as! StackedView
    }
}
