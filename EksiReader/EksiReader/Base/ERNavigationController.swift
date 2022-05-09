//
//  ERNavigationController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

class ERNavigationController: UINavigationController {
//    let uiBarBackground = self.navigationController?.navigationBar.subviews.first(where: { NSStringFromClass($0.classForCoder).contains("UIBarBackground") })
//    private let titleView = ERNavigationTitleView
//        .erNavigationTitleView()
    
    private var containerView = UIView(frame: .zero)
    private var containerBackgroundColor: UIColor = .clear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addContainerView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func addContainerView() {
        
        guard containerView.frame == .zero else {
            containerView.backgroundColor = containerBackgroundColor
            return
        }
        guard let uiBarBackground = self.navigationBar.subviews
                .first(where: { NSStringFromClass($0.classForCoder).contains("UIBarBackground") }) else { return }
        containerView = UIView(frame: .init(origin: .zero, size: .init(width: uiBarBackground.frame.size.width, height: uiBarBackground.frame.size.height)))
        containerView.autoresizingMask = [.flexibleHeight]
        uiBarBackground.insertSubview(containerView, at: 0)
        containerView.backgroundColor = containerBackgroundColor
    }
    
    func setBackgroundColor(_ color: UIColor) {
        containerBackgroundColor = color
        addContainerView()
        
        
    }
}
