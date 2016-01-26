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
    
    //MARK: - Support
    
    private func showWebView() {
        webView = UIWebView(frame: view.bounds)
        webView.delegate = self
        view.addSubview(webView)
        
        let urlString = "https://oauth.vk.com/authorize?" +
                        "client_id=5153671&display=mobile" +
                        "&redirect_uri=http://vkmusic.player" +
                        "&scope=audio" +
                        "&response_type=token" +
                        "&v=5.44&revoke=1"
        let oauthURL = NSURL(string: urlString)
        let urlRequest = NSURLRequest(URL: oauthURL!)
        webView.loadRequest(urlRequest)
    }
    
    private func addCancelButtonItem() {
        let cancelButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: Selector("cancel"))
        navigationItem.rightBarButtonItem = cancelButtonItem
    }
    
    //MARK: - Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCancelButtonItem()
        showWebView()
    }
    
    //MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL?.host == "vkmusic.player" {
            let absString: String! = request.URL?.absoluteString
            let count = "http://vkmusic.player/#".characters.count
            let index = "http://vkmusic.player/#".startIndex.advancedBy(count)
            let urlString = absString.substringFromIndex(index)
            let components = urlString.componentsSeparatedByString("&")
            if components[0].componentsSeparatedByString("=")[0] == "access_token" {
                let accessToken = AccessToken(components: components)
                if let comp = compelition {
                    comp(accessToken: accessToken)
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }

        }
        return true
    }
    
    //MARL: - Actions
    
    @objc private func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
        if let comp = compelition {
            comp(accessToken: nil)
        }
    }
}


