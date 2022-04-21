//
//  EksiTabbarController.swift
//  EksiReader
//
//  Created by aybek can kaya on 19.04.2022.
//

import Foundation
import UIKit

struct EksiTabbarItem {
    let image: UIImage
    let title: String
    let viewController: ERViewController
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

        let todayDataController = TopicListDataController()
        let todayRouter = TopicListRouter()
        let todayViewModel = TopicListViewModel(dataController: todayDataController, router: todayRouter)
        let todayViewController = TodayViewController(viewModel: todayViewModel)
        let todayNavCon = ERNavigationController(rootViewController: todayViewController)
        todayNavCon.tabBarItem = UITabBarItem(title: "Bugün", image: UIImage(systemName: "calendar"), selectedImage: nil)
        arrNavigationControllers.append(todayNavCon)

        let popularDataController = TopicListDataController()
        let popularRouter = TopicListRouter()
        let popularViewModel = TopicListViewModel(dataController: popularDataController, router: popularRouter)
        let popularViewController = PopularViewController(viewModel: popularViewModel)
        let popularNavCon = ERNavigationController(rootViewController: popularViewController)
        popularNavCon.tabBarItem = UITabBarItem(title: "Gündem", image: UIImage(systemName: "newspaper"), selectedImage: nil)
        arrNavigationControllers.append(popularNavCon)

        let searchDataController = TopicListDataController()
        let searchRouter = TopicListRouter()
        let searchViewModel = TopicListViewModel(dataController: searchDataController, router: searchRouter)
        let searchViewController = SearchViewController(viewModel: searchViewModel)
        let searchNavCon = ERNavigationController(rootViewController: searchViewController)
        searchNavCon.tabBarItem = UITabBarItem(title: "Ara", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)
        arrNavigationControllers.append(searchNavCon)

        let settingsDataController = TopicListDataController()
        let settingsRouter = TopicListRouter()
        let settingsViewModel = TopicListViewModel(dataController: settingsDataController, router: settingsRouter)
        let settingsViewController = SearchViewController(viewModel: settingsViewModel)
        let settingsNavCon = ERNavigationController(rootViewController: settingsViewController)
        settingsNavCon.tabBarItem = UITabBarItem(title: "Ayarlar", image: UIImage(systemName: "gearshape"), selectedImage: nil)
        arrNavigationControllers.append(settingsNavCon)


        viewControllers = arrNavigationControllers

        
//        var arrNavigationControllers: [ERNavigationController] = []
//        let images: [String] = ["calendar", "newspaper", "magnifyingglass", "gearshape"]
//        let titles: [String] = ["Bugün", "Gündem", "Ara", "Ayarlar"]
//        for index in 0 ..< 4 {
//            let image = UIImage(systemName: images[index])!
//            let item = tempViewController(image: image, title: titles[index])
//            let navCon = ERNavigationController(rootViewController: item.viewController)
//            navCon.tabBarItem = UITabBarItem.init(title: item.title, image: image, selectedImage: nil)
//            arrNavigationControllers.append(navCon)
//        }
//
//        viewControllers = arrNavigationControllers
    }

    private func tempViewController(image: UIImage, title: String) -> EksiTabbarItem {
        let todayDataController = TopicListDataController()
        let todayRouter = TopicListRouter()
        let todayViewModel = TopicListViewModel(dataController: todayDataController, router: todayRouter)
        let todayViewController = TopicListViewController(viewModel: todayViewModel)

        let sampleContainerViewController = ERViewController()
        sampleContainerViewController.addChildViewController(childController: todayViewController, onView: sampleContainerViewController.view)

      //  let sampleViewController = todayViewController
        let item = EksiTabbarItem(image: image, title: title, viewController: sampleContainerViewController)
        return item
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

