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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        EksiAnalytics.screenAppear(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        EksiAnalytics.screenDissapear(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.tintColor = Styling.Application.navigationBarTitleColor
        (self.navigationController as? ERNavigationController)?.setBackgroundColor(Styling.Application.navigationBarColor)
//        (self.navigationController?.navigationItem.titleView as? ERNavigationTitleView)?.setTitleLabelTextColor(Styling.Application.navigationBarTitleColor)

        titleView.reloadView()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addListeners()
    }

    func setTitle(_ title: String?) {
        titleView.setTitle(title)
    }
    
    private func setUpUI() {
        self.view.backgroundColor = Styling.Application.backgroundColor
        titleView.translatesAutoresizingMaskIntoConstraints = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        self.navigationItem.titleView = titleView
    }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(forName: ERKey.NotificationName.colorThemeChanged, object: nil, queue: nil) { [weak self] _ in
            self?.reloadViews()
        }
    }
    
    // Blueprint
    @objc func reloadViews() {
//        self.navigationController?.navigationBar.subviews.forEach {
//            NSLog("SubView: \($0)")
//        }
//
//        self.tabBarController?.tabBar.subviews.forEach {
//            NSLog("Tabbar Subview: \($0)")
//        }
        
        Anima.animate(with: .defaultAnimation(duration: 0.7, options: .curveEaseInOut)) {
           
            self.view.backgroundColor = Styling.Application.backgroundColor
            self.navigationController?.navigationBar.tintColor = Styling.Application.navigationBarTitleColor
            (self.navigationItem.titleView as? ERViewReloadable)?.reloadView()
          
//            let navBarAppearance = UINavigationBarAppearance()
//            navBarAppearance.configureWithOpaqueBackground()
//            navBarAppearance.backgroundColor = .red
//            navBarAppearance.shadowColor = .clear
//            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
//            UINavigationBar.appearance().standardAppearance = navBarAppearance
        }.start()
    }
}
