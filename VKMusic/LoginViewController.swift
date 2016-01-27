//
//  LoginViewController.swift
//  VKMusic
//
//  Created by Владимир Мельников on 25.01.16.
//  Copyright © 2016 vlmlnkv. All rights reserved.
//

import UIKit

typealias AuthorizationResponder = (accessToken: AccessToken?) -> Void

class LoginViewController: UIViewController, UIWebViewDelegate {
    
    var webView: UIWebView!
    var compelition: AuthorizationResponder?
    
    init(compelition: AuthorizationResponder) {
        self.compelition = compelition
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCancelButtonItem()
        showWebView()
    }
    
    //MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        parseRequest(request)
        return true
    }
    
    
    //MARK: - Support
    
    private func showWebView() {
        webView = UIWebView(frame: view.bounds)
        webView.delegate = self
        view.addSubview(webView)
        
        let urlString = "https://oauth.vk.com/authorize?" +
            "client_id=5153671" +
            "&display=mobile" +
            "&redirect_uri=http://vkmusic.player" +
            "&scope=audio" +
            "&response_type=token" +
            "&v=5.44"
        let oauthURL = NSURL(string: urlString)
        let urlRequest = NSURLRequest(URL: oauthURL!)
        webView.loadRequest(urlRequest)
    }
    
    private func addCancelButtonItem() {
        let cancelButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancelButtonPressed"))
        navigationItem.rightBarButtonItem = cancelButtonItem
    }
    
    private func parseRequest(request: NSURLRequest) {
        if request.URL?.host == "vkmusic.player" {
            var accessToken: AccessToken?
            let absString: String! = request.URL?.absoluteString
            let count = "http://vkmusic.player/#".characters.count
            let index = "http://vkmusic.player/#".startIndex.advancedBy(count)
            let urlString = absString.substringFromIndex(index)
            let components = urlString.componentsSeparatedByString("&")
            let tmp = components[0].componentsSeparatedByString("=")[0]
            if tmp == "access_token" {
                accessToken = AccessToken(components: components)
            }
            if let comp = compelition {
                comp(accessToken: accessToken)
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARL: - Actions
    
    @objc private func cancelButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
        if let comp = compelition {
            comp(accessToken: nil)
        }
    }
}


