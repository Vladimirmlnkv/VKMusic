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
        getAccessToken()
        
        if RequestManager.sharedManager.accessToken == nil {
            showLoginScreen()
        }
        
        return true
    }

    private func getAccessToken() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let token = defaults.objectForKey("token") as? String, userID = defaults.objectForKey("userID") as? String, expiresIn = defaults.objectForKey("expiresIn") as? String {
            RequestManager.sharedManager.accessToken = AccessToken(token: token, userID: userID, expiresIn: expiresIn)
        }
    }
    
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let startVC = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as! StartViewController
        let navVC = UINavigationController(rootViewController: startVC)
        window?.rootViewController = navVC
    }
}

