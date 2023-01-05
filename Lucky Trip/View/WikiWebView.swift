//
//  WikiWebView.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import Foundation
import UIKit
import WebKit

class WikiWebView: UIViewController, WKUIDelegate {
    
    var url: String?
    
    var webView: WKWebView!;override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: url!)
        if myURL != nil {
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        } else {
            print("URL null")
        }
    }
}
