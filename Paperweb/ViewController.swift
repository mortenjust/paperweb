//
//  ViewController.swift
//  Paperweb
//
//  Created by Morten Just Petersen on 9/28/18.
//  Copyright © 2018 Morten Just Petersen. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    
    @IBOutlet weak var menu: UIView!
    
    @IBOutlet weak var webView: WKWebView!
    
    override var prefersStatusBarHidden: Bool  { return true }
    
    var shouldRestoreScrollPosition = false
    
    @IBOutlet weak var hider: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       hideMenu()
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        
        webView.navigationDelegate =  self
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
 
        if let savedUrl = UserDefaults.standard.url(forKey: "url") {
            print("There was a saved item: \(savedUrl.absoluteString)")
            let url = savedUrl
            shouldRestoreScrollPosition = true
            let urlReq = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad , timeoutInterval: 60)
            webView.load(urlReq)
        } else {
            loadPage(url: "https://berlingske.dk")
        }
    }
    
    func loadPage(url u:String){
        let url = URL(string: u)!
        let urlReq = URLRequest(url: url)
        webView.load(urlReq)
    }
    
    func hideMenu(){
        menu.center.y -= menu.frame.height
    }
    
    func showMenu(){
        menu.center.y = 0
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        showMenu()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        hideMenu()
    }
    
    @IBAction func waPressed(_ sender: Any) {
        loadPage(url: "https://weekendavisen.dk")
    }
    
    @IBAction func bPressed(_ sender: Any) {
        loadPage(url: "https://berlingske.dk")
    }
    
    @IBAction func polPressed(_ sender: Any) {
        loadPage(url: "https://politiken.dk")
    }
    
    func saveScrollPosition(){
        print("saveScrollPosition")
        var y:CGFloat!
        
        webView.evaluateJavaScript("window.pageYOffset") { (scrollPos, err) in
            print("evaluated the script")
            print(scrollPos)
            y = scrollPos as! CGFloat
            // save to defaults
            UserDefaults.standard.set(Float(y), forKey: "scrollposition")
            print("saved position as \(y)")
        }

        // ios way
//        let y = webView.scrollView.contentOffset.y
//        UserDefaults.standard.set(Float(y), forKey: "scrollposition")

        UserDefaults.standard.set(webView.url, forKey: "url")
    }
    
    func restoreScrollPosition(){
        let restoredPosition = UserDefaults.standard.float(forKey: "scrollposition")
        print("restoreScrollPosition to position \(restoredPosition)")
        
        // ios way
//        webView.scrollView.contentOffset =  CGPoint(
//            x: CGFloat(0.0),
//            y: CGFloat(restoredPosition)
        
        // webway
        
        webView.evaluateJavaScript("window.scrollTo(0,\(restoredPosition))") { (result, err) in
            print("evaluated the script")
            print(result)
            print(err)
        }
        
        
    }
    
    // save current page and position
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        print("did scroll to \(y)")
        saveScrollPosition()
    }
    

    
    func removeHider(){
        UIView.animate(withDuration: 1) {
            self.hider.alpha = 0
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let reqUrl = navigationAction.request.url?.absoluteString
        print("- Decide policy action for \(reqUrl)")
        if (reqUrl?.contains("weekendavisen"))! {
            decisionHandler(.allow)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("+ Decide policy response for \(navigationResponse.response.url?.absoluteString)")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finished loading")
        if shouldRestoreScrollPosition  {
            restoreScrollPosition()
//            shouldRestoreScrollPosition = false
        }
        removeHider()
    }

    
    

}

