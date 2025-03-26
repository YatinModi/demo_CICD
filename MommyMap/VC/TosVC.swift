//
//  TosVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 11/10/24.
//

import UIKit
import UBottomSheet
import WebKit

class TosVC: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var vwTopSadow: UIView!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var scrollVw: UIScrollView!
    @IBOutlet weak var WebVw: WKWebView!

    var sheetCoordinator: UBottomSheetCoordinator?
    var TopTitle = ""
    var strUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.BackCalled(notfication:)), name: Notification.Name("BackCalledTos"), object: nil)

        self.SetupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }
    
    func SetupUI() {
        
        self.vwTopSadow.SetSadow(view: self.vwTopSadow)
        self.lblTopTitle.text = self.TopTitle
        
        NVActivityIndicatorViewable.show(myView: self.view)
        self.WebVw.navigationDelegate = self
//        if self.TopTitle == "Privacy" {
//            if let filePath = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "pdf") {
//                let fileURL = URL(fileURLWithPath: filePath)
//                let request = URLRequest(url: fileURL)
//                self.WebVw.load(request)
//            }
//        }else{
            if let url = URL(string: strUrl) {
                let request = URLRequest(url: url)
                self.WebVw.load(request)
            }
//        }
    }
    
    // Optional: Handle navigation events
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NVActivityIndicatorViewable.hide()
        print("Web page loaded successfully!")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load web page: \(error.localizedDescription)")
    }

}

extension TosVC: Draggable {
    func draggableView() -> UIScrollView? {
        return scrollVw
    }
    @IBAction func dismissAction() {
        NotificationCenter.default.post(name: Notification.Name("NormalMapDetails"), object: nil, userInfo: nil)
        sheetCoordinator?.removeSheetChild(item: self)
    }
    
    @objc func BackCalled(notfication: Notification) {
        sheetCoordinator?.removeSheetChild(item: self)
    }
    
}

