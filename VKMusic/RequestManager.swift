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
    
    //MARK: - VK Methods
    
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
    
    //MARK: - Requests
    
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, compeletion: (image: UIImage) -> Void) {
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                compeletion(image: UIImage(data: data)!)
            }
        }
    }
}