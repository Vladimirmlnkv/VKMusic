//
//  LoginManager.swift
//  VKMusic
//
//  Created by Владимир Мельников on 01.02.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

final class LoginManager {
    static let sharedManager = LoginManager()
//TODO: check if token expired
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
        
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let vkCookies = cookies.cookiesForURL(NSURL(string: "https://oauth.vk.com")!)
        if let vkc = vkCookies {
            for cookie in vkc {
                cookies.deleteCookie(cookie)
            }
        }
    }
    
    func login() {
        let appDelegate = UIApplication.sharedApplication().delegate
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let musicVC = storyboard.instantiateInitialViewController()
        appDelegate?.window??.rootViewController = musicVC
        RequestManager.sharedManager.saveToken()
    }
    
    func reloginIfNeeded() {
        let currentDate = NSDate(timeIntervalSinceNow: 0)
        if RequestManager.sharedManager.accessToken?.expiresIn.timeIntervalSinceDate(currentDate) > 0 {
            RequestManager.sharedManager.authorizeUser {
                RequestManager.sharedManager.saveToken()
            }
        }
    }
}