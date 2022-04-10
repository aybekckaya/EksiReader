//
//  UINib+Loading.swift
//  UINibLoading
//
//  Created by Aybek Can Kaya on 24.07.2021.
//

import Foundation
import UIKit

public protocol ComponentIdentifier: AnyObject {
    static var identifier: String { get }
}

public extension ComponentIdentifier {
    static var identifier: String { return String(describing: self) }
}


public extension UIView {
    class func loadNib<G: ComponentIdentifier>() -> G {
        guard let view = Bundle.main.loadNibNamed(G.identifier, owner: nil, options: nil)?[0] as? G else { fatalError() }
        return view
    }
}

public extension UITableView {
    func deque<G: ComponentIdentifier>(indexPath: IndexPath) -> G {
        guard let cell = self.dequeueReusableCell(withIdentifier: G.identifier, for: indexPath) as? G else { fatalError() }
        return cell
    }
}


public extension UICollectionView {
    func deque<G: ComponentIdentifier>(indexPath: IndexPath) -> G {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: G.identifier, for: indexPath) as? G else { fatalError() }
        return cell
    }

    func dequeHeaderView<G: ComponentIdentifier>(indexPath:IndexPath)->G {
        guard let view = self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: G.identifier, for: indexPath) as? G else { fatalError() }
        return view
    }
}

public protocol ControllerNibProtocol {
    static var identifier:String { get }
}

public extension ControllerNibProtocol {
    static var identifier: String { return String(describing: self) }
}


extension UIView: ComponentIdentifier {}
extension UIViewController:ControllerNibProtocol {}
