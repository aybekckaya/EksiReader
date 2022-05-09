//
//  ERNavigationTitleView.swift
//  EksiReader
//
//  Created by aybek can kaya on 21.04.2022.
//

import Foundation
import UIKit

class ERNavigationTitleView: UIView, ERViewReloadable {
    private let lblTitle = UILabel
        .label()
        .font(Styling.Application.navigationBarTitleFont)
        .textColor(Styling.Application.navigationBarTitleColor)
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
    
    func reloadView() {
        self.lblTitle.textColor = Styling.Application.navigationBarTitleColor
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
