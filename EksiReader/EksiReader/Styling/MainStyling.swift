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
            return DarkColorTheme.background
        }
    }
}

// MARK: - Navigation Bar
extension Styling.Application {
    static var navigationBarColor: UIColor {
        return DarkColorTheme.barColor
    }

    static var navigationBarTitleColor: UIColor {
        return DarkColorTheme.barTintColor
    }

    static var navigationBarTitleFont: UIFont {
        return C.Font.bold.font(size: 16)
    }
}

// MARK: - Tab Bar
extension Styling.Application {
    static var tabBarColor: UIColor {
        return DarkColorTheme.barColor
    }

    static var tabbarTintColor: UIColor {
        return DarkColorTheme.barTintColor
    }

    static var tabbarUnSelectedItemTintColor: UIColor {
        return DarkColorTheme.tabbarUnSelected
    }
}




