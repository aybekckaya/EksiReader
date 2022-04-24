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
            return C.Color.black
        }

        static var generalTextColor: UIColor {
            return C.Color.white
        }
    }
}

// MARK: - Navigation Bar
extension Styling.Application {
    static var navigationBarColor: UIColor {
        let val: CGFloat = 15 / 255.0
        return UIColor(red: val, green: val, blue: val, alpha: 1.0)
    }

    static var navigationBarTitleColor: UIColor {
        let val: CGFloat = 255.0 / 255.0
        return UIColor(red: val, green: val, blue: val, alpha: 1.0)
    }

    static var navigationBarTitleFont: UIFont {
        return C.Font.bold.font(size: 16)
    }
}

// MARK: - Tab Bar
extension Styling.Application {
    static var tabBarColor: UIColor {
        let val: CGFloat = 15 / 255.0
        return UIColor(red: val, green: val, blue: val, alpha: 1.0)
    }

    static var tabbarTintColor: UIColor {
        let val: CGFloat = 255.0 / 255.0
        return UIColor(red: val, green: val, blue: val, alpha: 1.0)
    }

    static var tabbarUnSelectedItemTintColor: UIColor {
        let val: CGFloat = 10.0 / 255.0
        return UIColor(red: val, green: val, blue: val, alpha: 1.0)
    }
}




