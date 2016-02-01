//
//  AppDelegate.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        RequestManager.sharedManager.loadToken()
        if RequestManager.sharedManager.accessToken == nil {
            LoginManager.sharedManager.showLoginScreen()
        }
        
        return true
    }
}

