//
//  SceneDelegate.swift
//  EksiReader
//
//  Created by aybek can kaya on 5.04.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let ws = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: ws)

//        UIFont.familyNames.forEach({ familyName in
//            let fontNames = UIFont.fontNames(forFamilyName: familyName)
//            print(familyName, fontNames)
//        })

//        let dataController = TopicListDataController()
//        let router = TopicListRouter()
//        let viewModel = TopicListViewModel(dataController: dataController, router: router)
//        let vc = TopicListViewController(viewModel: viewModel)
//        ERNavUtility.setWindowRoot(window: self.window, viewController: vc)

//        let dataController = TopicDataController(topicId: 7238539)
//        let router = TopicRouter()
//        let viewModel = TopicViewModel(dataController: dataController, router: router)
//        let vc = TopicViewController(viewModel: viewModel)
//        ERNavUtility.setWindowRoot(window: self.window, viewController: vc)

//        // 136159318
//        let router = EntryRouter()
//        let dataController = EntryDataController(entryId: 136159318)
//        let viewModel = EntryViewModel(dataController: dataController, router: router)
//        let viewController = EntryVC(viewModel: viewModel)
//        ERNavUtility.setWindowRoot(window: self.window, viewController: viewController)



//           self.tabController.tabBar.standardAppearance = appearance
//           self.tabController.tabBar.scrollEdgeAppearance = view.standardAppearance
        let tabbarController = EksiTabbarController()
        ERNavUtility.initialize(with: window, tabBarController: tabbarController)
        ERNavUtility.showRootViewController()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        APP.deInitialize()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        APP.initialize()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

