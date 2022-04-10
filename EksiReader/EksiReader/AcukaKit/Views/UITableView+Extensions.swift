//
//  UITableView+Extensions.swift
//  PodnaTrainer
//
//  Created by aybek can kaya on 12.10.2021.
//

import Foundation
import UIKit


extension UITableView {
    public func reload() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
