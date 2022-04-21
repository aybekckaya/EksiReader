//
//  NavigationUtility.swift
//  EksiReader
//
//  Created by aybek can kaya on 10.04.2022.
//

import Foundation
import UIKit

let ERNavUtility = NavigationUtility()

class NavigationUtility {
    private var tabBarController: EksiTabbarController!

    private var activeNavigationController: ERNavigationController {
        let viewControllers = tabBarController.viewControllers!
        let currentIndex = tabBarController.selectedIndex
        let currentNavConStack = viewControllers[currentIndex] as! ERNavigationController
        return currentNavConStack
    }

    public func initialize() {
        let val: CGFloat = 10 / 255
        let barColor = UIColor(red: val, green: val, blue: val, alpha: 1.0)

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = barColor
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance

        let tabbarAppearance = UITabBarAppearance()
        tabbarAppearance.configureWithOpaqueBackground()
        tabbarAppearance.backgroundColor = barColor

        UITabBar.appearance().scrollEdgeAppearance = tabbarAppearance
        UITabBar.appearance().standardAppearance = tabbarAppearance
    }


    public func setWindowRoot(window: UIWindow?, tabBarController: EksiTabbarController) {
        self.tabBarController = tabBarController
        window?.rootViewController = self.tabBarController
        window?.makeKeyAndVisible()
    }

    public func push(viewController: ERViewController) {
        activeNavigationController.pushViewController(viewController, animated: true)
    }

    public func showActivityViewController(_ viewController: UIActivityViewController) {
        viewController.popoverPresentationController?.sourceView = activeNavigationController.view
        activeNavigationController.present(viewController, animated: true) {
            
        }
    }
    
}
