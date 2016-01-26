//
//  RequestManager.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import Alamofire

class RequestManager {
    static let sharedManager = RequestManager()
    var accessToken: AccessToken?
    
    //MARK: - Requests
    
    func authorizeUser(success: (Void) -> Void) {
        let loginVC = LoginViewController { (accessToken) -> Void in
            self.accessToken = accessToken
            if let _ = self.accessToken {
                success()
            }
        }
        let navVC = UINavigationController(rootViewController: loginVC)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainVC = appDelegate.window?.rootViewController
        mainVC?.presentViewController(navVC, animated: true, completion: nil)
    }
    
    func getAudios(success: (serverData: [AnyObject]) -> Void) {
        let parameters = [
            "owner_id" : accessToken!.userID,
            "access_token" : accessToken!.token
        ]
        Alamofire.request(.GET, "https://api.vk.com/method/audio.get", parameters: parameters)
                 .responseJSON { response in
                    if let serverData = response.result.value!["response"]! as? [AnyObject]{
                        let data = Array(serverData[1..<serverData.count])
                        success(serverData: data)
                    }
        }
    }
}