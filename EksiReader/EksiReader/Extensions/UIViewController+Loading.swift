//
//  UIViewController+Loading.swift
//  EksiReader
//
//  Created by aybek can kaya on 22.04.2022.
//

import Foundation
import UIKit

extension ERViewController {
    func showFullSizeLoading() {
        EksiLoadingView.show(in: self.view)
    }

    func hideFullSizeLoading() {
        EksiLoadingView.hide(from: self.view)
    }
}


extension UIViewController {
    var statusBarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20.0)
    }

    var navigationBarHeight: CGFloat {
        return (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }

    var topbarHeight: CGFloat {
            return statusBarHeight + navigationBarHeight
        }
}
