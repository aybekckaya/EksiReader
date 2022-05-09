//
//  MainStyling.swift
//  EksiReader
//
//  Created by aybek can kaya on 16.04.2022.
//

import Foundation
import UIKit

struct Styling {

}

// MARK: - Application
extension Styling {
    struct Application {
        static var backgroundColor: UIColor {
            let colorTheme = APP.themeManager.getCurrentTheme()
            return colorTheme.background
        }
    }
}

// MARK: - Navigation Bar
extension Styling.Application {
    static var navigationBarColor: UIColor {
        return APP.themeManager.getCurrentTheme().barColor
    }

    static var navigationBarTitleColor: UIColor {
        return APP.themeManager.getCurrentTheme().barTintColor
    }

    static var navigationBarTitleFont: UIFont {
        return C.Font.bold.font(size: 16)
    }
}

// MARK: - Tab Bar
extension Styling.Application {
    static var tabBarColor: UIColor {
        return APP.themeManager.getCurrentTheme().barColor
    }

    static var tabbarTintColor: UIColor {
        return APP.themeManager.getCurrentTheme().barTintColor
    }

    static var tabbarUnSelectedItemTintColor: UIColor {
        return APP.themeManager.getCurrentTheme().tabbarUnSelected
    }
}




