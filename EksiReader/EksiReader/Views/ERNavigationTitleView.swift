//
//  ERNavigationTitleView.swift
//  EksiReader
//
//  Created by aybek can kaya on 21.04.2022.
//

import Foundation
import UIKit

class ERNavigationTitleView: UIView {
    private let lblTitle = UILabel
        .label()
        .font(C.Font.bold.font(size: 16))
        .textColor(.white)
        .alignment(.center)
        .numberOfLines(0)

    init() {
        super.init(frame: .zero)

        lblTitle
            .add(into: self)
            .fit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String?) {
        lblTitle.text = title
    }
}

// MARK: - Declarative UI
extension ERNavigationTitleView {
    static func erNavigationTitleView() -> ERNavigationTitleView {
        let view = ERNavigationTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
}

extension UIView {
    func asERNavigationTitleView() -> ERNavigationTitleView {
        return self as! ERNavigationTitleView
    }
}