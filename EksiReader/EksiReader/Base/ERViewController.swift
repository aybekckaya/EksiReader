//
//  ERViewController.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

class ERViewController: UIViewController {

    private let titleView = ERNavigationTitleView
        .erNavigationTitleView()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EksiAnalytics.screenAppear(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        EksiAnalytics.screenDissapear(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.colorThemeChanged, object: nil, queue: nil) { _ in
           // self.view.backgroundColor = Styling.Application.backgroundColor
            self.view.setNeedsDisplay()
        }
        
        self.view.backgroundColor = Styling.Application.backgroundColor
        self.navigationController?.navigationBar.barTintColor = Styling.Application.navigationBarColor
        self.navigationController?.navigationBar.tintColor = Styling.Application.navigationBarTitleColor

        titleView.translatesAutoresizingMaskIntoConstraints = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.navigationItem.titleView = titleView
    }

    func setTitle(_ title: String?) {
        titleView.setTitle(title)
    }
}
