//
//  ERNavigationController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

protocol BarContainerBackgroundProtocol: AnyObject {
    var barBackgroundColor: UIColor { get set }
    var barSubviews: [UIView] { get }
     func setBarBackground(backgroundColor: UIColor)
}

extension BarContainerBackgroundProtocol {
     func setBarBackground(backgroundColor: UIColor) {
        barBackgroundColor = backgroundColor
        if let containerView = findContainerView() {
            containerView.backgroundColor = backgroundColor
        } else if let view = addContainerView() {
            view.backgroundColor = backgroundColor
        }
    }

    private func addContainerView() -> UIView? {
        guard let bgView = findBarBackground() else { return nil }
        let containerView = UIView(frame: .init(origin: .zero,
                                                size: .init(width: bgView.frame.size.width,
                                                            height: bgView.frame.size.height)))
        containerView.tag = 9001
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.addSubview(containerView)
        return containerView
    }

    private func findContainerView() -> UIView? {
        guard let bg = findBarBackground() else { return nil }
        return bg.subviews.first { $0.tag == 9001 }
    }

    private func findBarBackground() -> UIView? {
        guard let uiBarBackground = barSubviews
                .first(where: { NSStringFromClass($0.classForCoder).contains("UIBarBackground") })
        else { return nil }
        return uiBarBackground
    }
}

class ERNavigationController: UINavigationController, BarContainerBackgroundProtocol {
    var barBackgroundColor: UIColor = .clear

    var barSubviews: [UIView] {
        self.navigationBar.subviews
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBarBackground(backgroundColor: barBackgroundColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setBackgroundColor(_ color: UIColor) {
        barBackgroundColor = color
        setBarBackground(backgroundColor: color)
    }

    func setTintColor(_ color: UIColor) {
        self.navigationBar.tintColor = color
    }
}
