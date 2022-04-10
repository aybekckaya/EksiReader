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

    private var activeNavigationController: ERNavigationController?

    public func setWindowRoot(window: UIWindow?, viewController: ERViewController) {
        let navCon = ERNavigationController(rootViewController: viewController)
        self.activeNavigationController = navCon
        window?.rootViewController = navCon
        window?.makeKeyAndVisible()
    }

    public func push(viewController: ERViewController) {
        guard let activeNavigationController = activeNavigationController else {
            return
        }
        activeNavigationController.pushViewController(viewController, animated: true)
    }

    
}
