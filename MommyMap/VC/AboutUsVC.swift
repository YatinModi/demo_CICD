//
//  AboutUsVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 18/11/24.
//

import UIKit
import UBottomSheet

class AboutUsVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var vwTopSadow: UIView!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var txtVw: UITextView!
    @IBOutlet weak var scrollVw: UIScrollView!

//    var sheetCoordinator: UBottomSheetCoordinator?

    let linkText = "(Read about it here in the 2006 Globe and Mail article)"
    let linkURL = "https://docs.google.com/document/d/1lxNwabk8HqW5L0afGSMh_Aen3RgPl_E7OkerjwaX4YA/edit?tab=t.0"
    let linkText1 = "Getyoteam Solution llp"
    let linkURL1 = "https://getyoteam.com/"

    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(self.BackCalled(notfication:)), name: Notification.Name("BackCalledAbout"), object: nil)
        self.SetupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        sheetCoordinator?.startTracking(item: self)
    }
    
    func SetupUI() {
        
        self.txtVw.delegate = self
        self.vwTopSadow.SetSadow(view: self.vwTopSadow)
        
        let fullText = self.txtVw.text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
      
        if let range = fullText.range(of: self.linkText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.link, value: self.linkURL, range: nsRange)
        }
        
        if let range1 = fullText.range(of: self.linkText1) {
            let nsRange = NSRange(range1, in: fullText)
            attributedString.addAttribute(.link, value: self.linkURL1, range: nsRange)
        }
        let settingAttribute2: [NSAttributedString.Key: Any] = [
            .font: UIFont.init(name: "Comfortaa", size: 15.0)!,
            .underlineStyle: NSUnderlineStyle.single.rawValue]
        let nsRangeUnderLine = NSString(string: fullText)
            .range(of: self.linkText1, options: String.CompareOptions.caseInsensitive)
        attributedString.addAttributes(settingAttribute2, range: nsRangeUnderLine)

        attributedString.addAttributes([.font: UIFont.init(name: "Comfortaa", size: 15)!], range: NSRange(location: 0, length: fullText.count))

        txtVw.isEditable = false
        txtVw.isSelectable = true
        txtVw.delegate = self
        txtVw.attributedText = attributedString
    }
    
    // Handle link tap
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // Open the URL
        UIApplication.shared.open(URL)
        return false // Prevent the system from handling it further
    }
    
}

extension AboutUsVC {
//    func draggableView() -> UIScrollView? {
//        return scrollVw
//    }
    @IBAction func dismissAction() {
//        NotificationCenter.default.post(name: Notification.Name("NormalMapDetails"), object: nil, userInfo: nil)
//        sheetCoordinator?.removeSheetChild(item: self)
        self.navigationController?.popViewController(animated: false)
    }
    @objc func BackCalled(notfication: Notification) {
//        sheetCoordinator?.removeSheetChild(item: self)
        self.navigationController?.popViewController(animated: false)
    }
}
