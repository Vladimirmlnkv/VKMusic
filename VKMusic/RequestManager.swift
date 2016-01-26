//
//  RequestManager.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit


class RequestManager {
    static let sharedManager = RequestManager()
    var accessToken: AccessToken?

    func authorizeUser() {
        let loginVC = LoginViewController { (accessToken) -> Void in
            self.accessToken = accessToken
            print(accessToken)
        }
        let navVC = UINavigationController(rootViewController: loginVC)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainVC = appDelegate.window?.rootViewController
        mainVC?.presentViewController(navVC, animated: true, completion: nil)
    }
}