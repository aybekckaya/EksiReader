//
//  TappableInputView.swift
//  EksiReader
//
//  Created by aybek can kaya on 26.04.2022.
//

import Foundation
import UIKit

class TappableInputView: UIView {
    private let contentView = UIView
        .view()

    private let lblTitle = UILabel
        .label()
        .font(C.Font.bold.font(size: 15))
        .textColor(.white)
        .alignment(.center)

    private let imViewIcon = UIImageView
        .imageView()
        .contentMode(.scaleAspectFit)


    init() {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        contentView
            .add(into: self)
            .top(.constant(8))
            .leading(.constant(24))
            .trailing(.constant(24))
            .bottom(.constant(8))
            .height(.constant(48))

        contentView.roundCorners(by: 8)

        let stackView = UIStackView
            .stackView(alignment: .fill, distribution: .fill, spacing: 8, axis: .horizontal)

        stackView
            .add(into: self.contentView)
            .fit(edges: .fill(with: 8))

//        imViewIcon
//            .add(intoStackView: stackView)
//            .width(.constant(24))
//            .height(.constant(24))

        lblTitle
            .add(intoStackView: stackView)

    }

    func configure(title: String, backgroundColor: UIColor, image: UIImage? = nil) {
        contentView.backgroundColor = backgroundColor
        lblTitle.text = title
        imViewIcon.image = UIImage(systemName: "circle.grid.3x3")
        imViewIcon.tintColor = lblTitle.textColor
    }
}

// MARK: - Declarative UI
extension TappableInputView {
    static func tappableInputView() -> TappableInputView {
        let view = TappableInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asTappableInputView() -> TappableInputView {
        return self as! TappableInputView
    }
}
