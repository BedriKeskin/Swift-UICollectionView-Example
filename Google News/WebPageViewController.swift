//
//  WebPageViewController.swift
//  Google News
//
//  Created by Bedri Keskin on 12.02.2022.
//  Copyright © 2022 Bedri Keskin. All rights reserved.
//

import UIKit
import WebKit

class WebPageViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    var link = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        let request = URLRequest(url: URL(string: link)!)
        webView.load(request)
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.view.addSubview(webView)
    }
}

