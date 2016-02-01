//
//  LoginManager.swift
//  VKMusic
//
//  Created by Владимир Мельников on 01.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

class LoginManager {
    static let sharedManager = LoginManager()

    func showLoginScreen() {
        let appDelegate = UIApplication.sharedApplication().delegate
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let startVC = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as! StartViewController
        let navVC = UINavigationController(rootViewController: startVC)
        appDelegate?.window??.rootViewController = navVC
    }
    
    func logout() {
        RequestManager.sharedManager.removeToken()
        showLoginScreen()
    }
    
    func login() {
        let appDelegate = UIApplication.sharedApplication().delegate
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let musicVC = storyboard.instantiateInitialViewController()
        appDelegate?.window??.rootViewController = musicVC
        RequestManager.sharedManager.saveToken()
    }
}