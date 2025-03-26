//
//  SpecificItemDetailsVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 10/10/24.
//

import UIKit
import UBottomSheet
import MapKit

class SpecificItemDetailsVC: UIViewController {
    
    @IBOutlet weak var vwTopSadow: UIView!
    @IBOutlet weak var scrollVw: UIScrollView!
    
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var lblTopAddress: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblDiaperChangingArea: UILabel!
    @IBOutlet weak var lblBreastFeedingFriendly: UILabel!
    @IBOutlet weak var lblPlayArea: UILabel!
    @IBOutlet weak var lblKidsMenu: UILabel!

    var sheetCoordinator: UBottomSheetCoordinator?
    var TopTitle = ""
    var FirebaseDataArr : firebaseDataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.BackCalled(notfication:)), name: Notification.Name("BackCalled"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getPercentageValue(notfication:)), name: Notification.Name("getPercentageValue"), object: nil)

        self.SetupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }
    
    func SetupUI() {
        self.lblTopTitle.text = self.TopTitle.uppercased()
        self.lblTopAddress.text = self.FirebaseDataArr.addressShortForm.uppercased()
        self.lblNote.text = "" //self.FirebaseDataArr.notesReCalendar
        self.lblDiaperChangingArea.text = self.FirebaseDataArr.diaperChangingArea.uppercased()
        self.lblBreastFeedingFriendly.text = self.FirebaseDataArr.breastFeedingFriendly.uppercased()
        self.lblPlayArea.text = self.FirebaseDataArr.playArea.uppercased()
        self.lblKidsMenu.text = self.FirebaseDataArr.kidsMenu.uppercased()
        
        self.setHeaderShadow(opacity: 0.0)
    }
    
    @objc func openGoogleMaps() {
        let address = self.FirebaseDataArr.address ?? ""
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "https://maps.google.com/?q=\(encodedAddress)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.view.makeToast("Google Maps app is not insta1lled.")
            }
        }
    }
    @objc func openAppleMaps() {
        let address = self.FirebaseDataArr.address ?? ""
        let escapedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "http://maps.apple.com/?q=\(escapedAddress)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func BackCalled(notfication: Notification) {
        sheetCoordinator?.removeSheetChild(item: self)
    }
    @objc func getPercentageValue(notfication: Notification) {
        if self.appDelegate.PercentageValue >= 100.0 {
//            self.setHeaderShadow(opacity: 0.3)
            self.setHeaderShadow(opacity: 0.0)
        }else{
            self.setHeaderShadow(opacity: 0.0)
        }
    }
    
    private func setHeaderShadow(opacity: Float, animated: Bool = true) {
        vwTopSadow.layer.shadowColor = UIColor.black.cgColor
        vwTopSadow.layer.shadowOffset = CGSize(width: 0, height: 1)
        vwTopSadow.layer.shadowRadius = 2
        vwTopSadow.layer.masksToBounds = false
        let duration = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration) {
            self.vwTopSadow.layer.shadowOpacity = opacity
        }
    }

}

extension SpecificItemDetailsVC: Draggable {
    func draggableView() -> UIScrollView? {
        return scrollVw
    }
}

//Mark:- UIButton Action
extension SpecificItemDetailsVC {
    @IBAction func btnOpenMap(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .default, handler: { _ in
            self.openAppleMaps()
        }))
        actionSheet.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            self.openGoogleMaps()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    @IBAction func btnShare(_ sender: UIButton) {
        let text = self.FirebaseDataArr.website
        let shareAll = [text]
        let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func btnWbsite(_ sender: UIButton) {
        if let url = URL(string: self.FirebaseDataArr.website) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func dismissAction() {
        NotificationCenter.default.post(name: Notification.Name("NormalMapDetails"), object: nil, userInfo: nil)
        sheetCoordinator?.removeSheetChild(item: self)
    }
}
