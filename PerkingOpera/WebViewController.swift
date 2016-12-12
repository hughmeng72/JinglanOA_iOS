//
//  WebViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/4/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {

    var urlString: String!
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Loading " + self.urlString)
        
        let url = URL(string: self.urlString)
        let request = URLRequest(url: url!)
        webView.load(request)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
