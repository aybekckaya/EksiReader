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
