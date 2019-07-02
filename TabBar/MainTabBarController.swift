//
//  MainTabBarController.swift
//  mp
//
//  Created by DANIEL I QUINTERO on 6/21/17.
//  Copyright © 2017 DanielIQuintero. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        UITabBar.appearance().barTintColor = UIColor.white
        let projectsViewController = ProjectViewController()
        let navController = UINavigationController(rootViewController: projectsViewController)
        navController.tabBarItem.image = #imageLiteral(resourceName: "projects_off_").withRenderingMode(.alwaysOriginal)
        navController.tabBarItem.selectedImage = #imageLiteral(resourceName: "projects_pressed_").withRenderingMode(.alwaysOriginal)
       
        let stockViewController = StockDataViewController()
        let stockNavController = UINavigationController(rootViewController: stockViewController)
            stockNavController.tabBarItem.image = #imageLiteral(resourceName: "stock_data_off_").withRenderingMode(.alwaysOriginal)  
            stockNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "stock_data_pressed_").withRenderingMode(.alwaysOriginal)
        //>>>>
        
        let maintenanceViewController = MaintenanceViewController()
        let maintenanceNavController = UINavigationController(rootViewController: maintenanceViewController)
            maintenanceNavController.tabBarItem.image = #imageLiteral(resourceName: "wrench_off_").withRenderingMode(.alwaysOriginal)
            maintenanceNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "wrench_pressed_").withRenderingMode(.alwaysOriginal)
        //>>>>
        
        let videoListViewController = TutorialListViewController()
        let videoNavController = UINavigationController(rootViewController: videoListViewController)
        videoNavController.tabBarItem.image = #imageLiteral(resourceName: "video_off").withRenderingMode(.alwaysOriginal)
        videoNavController.tabBarItem.selectedImage = #imageLiteral(resourceName: "video_pressed").withRenderingMode(.alwaysOriginal)
        //
        //>>>>
        
        viewControllers = [navController, stockNavController, maintenanceNavController, videoNavController]
        
        //modify tab bar insets
        guard let items = tabBar.items else {return}
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNavController(vc: UIViewController, selectedImage: UIImage, unselectedImage: UIImage) {
       
        let viewController = vc
        _ = UINavigationController(rootViewController: viewController)
        viewController.tabBarItem.image = unselectedImage
        viewController.tabBarItem.selectedImage = selectedImage
        viewController.view.backgroundColor = .white
    }
}
