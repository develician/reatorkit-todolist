//
//  AppDelegate.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.makeKeyAndVisible()
        let serviceProvider = ServiceProvider()
        let todoListReactor = TodoListReactor(provider: serviceProvider)
        let todoListViewController = TodoListViewController(reactor: todoListReactor)
        let todoListNavigationController = UINavigationController(rootViewController: todoListViewController)
        window?.rootViewController = todoListNavigationController
    
        return true
    }


}

