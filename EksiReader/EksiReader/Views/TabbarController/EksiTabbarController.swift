//
//  EksiTabbarController.swift
//  EksiReader
//
//  Created by aybek can kaya on 19.04.2022.
//

import Foundation
import UIKit

enum EksiTabbarItem {
    case today
    case popular
    case search
    case settings

    var title: String {
        switch self {
        case .today:
            return "Bugün"
        case .settings:
            return "Ayarlar"
        case .search:
            return "Ara"
        case .popular:
            return "Gündem"
        }
    }

    var icon: String {
        switch self {
        case .today:
            return "calendar"
        case .settings:
            return "gearshape"
        case .search:
            return "magnifyingglass"
        case .popular:
            return "newspaper"
        }
    }

//    func endpoint(for page: Int) -> EREndpoint? {
//        switch self {
//        case .today:
//            return .today(page: page)
//        case .popular:
//            return nil
//        case .search:
//            return nil
//        case .settings:
//            return nil
//        }
//    }

}

class EksiTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabbarItems()
        setupUI()
    }

    func setupUI() {
        self.tabBar.unselectedItemTintColor = UIColor.black
        self.tabBar.tintColor = UIColor.white
    }

    private func tabbarItems() {
        var arrNavigationControllers: [ERNavigationController] = []

        let todayDataController = TopicListDataController(tabbarItem: .today)
        let todayRouter = TopicListRouter()
        let todayViewModel = TopicListViewModel(dataController: todayDataController, router: todayRouter)
        let todayViewController = TodayViewController(viewModel: todayViewModel)
        let todayNavCon = ERNavigationController(rootViewController: todayViewController)
        todayNavCon.tabBarItem = UITabBarItem(title: EksiTabbarItem.today.title,
                                              image: UIImage(systemName: EksiTabbarItem.today.icon),
                                              selectedImage: nil)
        arrNavigationControllers.append(todayNavCon)

        let popularDataController = TopicListDataController(tabbarItem: .popular)
        let popularRouter = TopicListRouter()
        let popularViewModel = TopicListViewModel(dataController: popularDataController, router: popularRouter)
        let popularViewController = PopularViewController(viewModel: popularViewModel)
        let popularNavCon = ERNavigationController(rootViewController: popularViewController)
        popularNavCon.tabBarItem = UITabBarItem(title: EksiTabbarItem.popular.title,
                                                image: UIImage(systemName: EksiTabbarItem.popular.icon),
                                                selectedImage: nil)
        arrNavigationControllers.append(popularNavCon)

        let searchDataController = TopicListDataController(tabbarItem: .search)
        let searchRouter = TopicListRouter()
        let searchViewModel = TopicListViewModel(dataController: searchDataController, router: searchRouter)
        let searchViewController = SearchViewController(viewModel: searchViewModel)
        let searchNavCon = ERNavigationController(rootViewController: searchViewController)
        searchNavCon.tabBarItem = UITabBarItem(title: EksiTabbarItem.search.title,
                                               image: UIImage(systemName: EksiTabbarItem.search.icon),
                                               selectedImage: nil)
        arrNavigationControllers.append(searchNavCon)

        let settingsDataController = TopicListDataController(tabbarItem: .settings)
        let settingsRouter = TopicListRouter()
        let settingsViewModel = TopicListViewModel(dataController: settingsDataController, router: settingsRouter)
        let settingsViewController = SearchViewController(viewModel: settingsViewModel)
        let settingsNavCon = ERNavigationController(rootViewController: settingsViewController)
        settingsNavCon.tabBarItem = UITabBarItem(title: EksiTabbarItem.settings.title,
                                                 image: UIImage(systemName: EksiTabbarItem.settings.icon),
                                                 selectedImage: nil)
        arrNavigationControllers.append(settingsNavCon)

        viewControllers = arrNavigationControllers
    }


    func setupViewController() {
        var arrNavCon: [ERNavigationController] = []
        var navCon: ERNavigationController
        var viewController: ERViewController

        viewController = SampleVCA()
        navCon = ERNavigationController(rootViewController: viewController)
        navCon.tabBarItem = UITabBarItem.init(title: "Tab 1", image: UIImage(systemName: "paperplane.fill"), selectedImage: nil)
        arrNavCon.append(navCon)

        viewController = SampleVCB()
        navCon = ERNavigationController(rootViewController: viewController)
        navCon.tabBarItem = UITabBarItem.init(title: "Tab 2", image: UIImage(systemName: "paperplane.fill"), selectedImage: nil)
        arrNavCon.append(navCon)

        viewController = SampleVCC()
        navCon = ERNavigationController(rootViewController: viewController)
        navCon.tabBarItem = UITabBarItem.init(title: "Tab 3", image: UIImage(systemName: "paperplane.fill"), selectedImage: nil)
        arrNavCon.append(navCon)



        self.viewControllers = arrNavCon
    }
}


class SampleVCA: ERViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    }
}

class SampleVCB: ERViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green

        UIView
            .view()
            .add(into: self.view)
            .centerX(.constant(0))
            .centerY(.constant(0))
            .width(.constant(100))
            .height(.constant(50))
            .backgroundColor(.white)
            .onTap { _ in
                let vc = SampleVCC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
    }
}


class SampleVCC: ERViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    }
}

