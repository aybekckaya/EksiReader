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
    private var window: UIWindow!

    private var activeNavigationController: ERNavigationController {
        let viewControllers = tabBarController.viewControllers!
        let currentIndex = tabBarController.selectedIndex
        let currentNavConStack = viewControllers[currentIndex] as! ERNavigationController
        return currentNavConStack
    }

    public func initialize(with window: UIWindow?, tabBarController: EksiTabbarController) {
        self.tabBarController = tabBarController
        self.window = window!
//        self.tabBar.unselectedItemTintColor = UIColor.black
//        self.tabBar.tintColor = UIColor.white
//
//        let appearance = UITabBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .red
//        self.tabBar.scrollEdgeAppearance = appearance
//        self.tabBar.standardAppearance = appearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = Styling.Application.navigationBarColor
        navBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance

        let tabbarAppearance = UITabBarAppearance()
        tabbarAppearance.configureWithOpaqueBackground()
        tabbarAppearance.backgroundColor = Styling.Application.tabBarColor

        UITabBar.appearance().scrollEdgeAppearance = tabbarAppearance
        UITabBar.appearance().standardAppearance = tabbarAppearance
        tabBarController.tabBar.unselectedItemTintColor = Styling.Application.tabbarUnSelectedItemTintColor
        tabBarController.tabBar.tintColor = Styling.Application.tabbarTintColor
    }

    public func showRootViewController() {
        window.rootViewController = self.tabBarController
        window.makeKeyAndVisible()
    }

    public func topMostViewController() -> UIViewController? {
        return window.visibleViewController()
    }

    public func push(viewController: ERViewController) {
        activeNavigationController.pushViewController(viewController, animated: true)
    }

    public func showActivityViewController(_ viewController: UIActivityViewController) {
        viewController.popoverPresentationController?.sourceView = activeNavigationController.view
        activeNavigationController.present(viewController, animated: true) {
            
        }
    }

    public func showBottomSheetViewController(_ viewController: ERViewController) {
        viewController.modalPresentationStyle = .pageSheet
        viewController.sheetPresentationController?.detents = [.medium()]
        activeNavigationController.present(viewController, animated: true) {
            
        }
    }
    
}

extension UIWindow {

    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }

    static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIWindow.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

//let detailViewController = DetailViewController()
//    let nav = UINavigationController(rootViewController: detailViewController)
//    // 1
//    nav.modalPresentationStyle = .pageSheet
//
//
//    // 2
//    if let sheet = nav.sheetPresentationController {
//
//        // 3
//        sheet.detents = [.medium(), .large()]
//
//    }
//    // 4
//    present(nav, animated: true, completion: nil)
