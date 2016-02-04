//
//  RequestManager.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit
import Alamofire

final class RequestManager {
    static let sharedManager = RequestManager()
    var accessToken: AccessToken?
    
    //MARK: - VK Methods
    
    func authorizeUser(success: (Void) -> Void) {
        let loginVC = LoginViewController { (accessToken) -> Void in
            if let token = accessToken {
                self.accessToken = token
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
    
    func searchAudios(searchText searchText: String, offset: Int, count: Int, success: (serverData: [AnyObject]) -> Void) {
        let parameters = [
            "q" : searchText,
            "auto_complete" : 1,
            "sort" : 2,
            "offset" : offset,
            "count" : count,
            "access_token" : accessToken!.token]
        
        Alamofire.request(.GET, "https://api.vk.com/method/audio.search", parameters: parameters as? [String : AnyObject])
                 .responseJSON { response in
                    if let serverData = response.result.value!["response"]! as? [AnyObject]{
                        let data = Array(serverData[1..<serverData.count])
                        success(serverData: data)
                    }
        }
    }
    
    func addAudio(audio: Audio, success: (newID: Int) -> Void) {
        let parameters = ["audio_id" : audio.id,
                            "owner_id" : audio.ownerID,
                            "access_token" : accessToken!.token]
        Alamofire.request(.GET, "https://api.vk.com/method/audio.add", parameters: parameters as? [String: AnyObject])
                .responseJSON {response in
                    let newID = response.result.value!["response"] as? Int
                    if let id = newID {
                        success(newID: id)
                    }
                }
    }
    
    func deleteAudio(audio: Audio, success: (Void) -> Void) {
        let parameters = ["audio_id" : audio.id,
                            "owner_id" : audio.ownerID,
                            "access_token" : accessToken!.token]
        Alamofire.request(.GET, "https://api.vk.com/method/audio.delete", parameters: parameters as? [String: AnyObject])
            .responseJSON { response in
                if let resp = response.result.value!["response"] as? Int {
                    if resp == 1 {
                        success()
                    }
                }
        }
    }
    
    //MARK: - Token Methods
    
    func removeToken() {
        accessToken = nil
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("token")
        defaults.removeObjectForKey("userID")
        defaults.removeObjectForKey("expiresIn")
    }
    
    func saveToken() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(accessToken!.token, forKey: "token")
        defaults.setObject(accessToken!.userID, forKey: "userID")
        defaults.setObject(accessToken!.expiresIn, forKey: "expiresIn")
    }
    
    func loadToken() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let token = defaults.objectForKey("token") as? String, userID = defaults.objectForKey("userID") as? String, expiresIn = defaults.objectForKey("expiresIn") as? String {
            accessToken = AccessToken(token: token, userID: userID, expiresIn: expiresIn)
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