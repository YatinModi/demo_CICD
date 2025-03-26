//
//  AreaCategoryDetailsVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 09/10/24.
//

import UIKit
import UBottomSheet

class AreaCategoryDetailsVC: UIViewController {

    @IBOutlet weak var vwTopSadow: UIView!
    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var tblVw: UITableView!

    var sheetCoordinator: UBottomSheetCoordinator?
    var TopTitle = ""
    var isCategory = false
    var isFromSection = false
    var isFromAmenities = false
    var ArrSelectedAmenities : NSMutableArray = []

    var FirebaseDataArr = [firebaseDataModel]()
    var FilterByDetailsClosure: ((_ strName: String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.BackCalledArea(notfication:)), name: Notification.Name("BackCalledArea"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getPercentageValue(notfication:)), name: Notification.Name("getPercentageValueArea"), object: nil)

        self.SetupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }
    
    func SetupUI() {
        
        self.lblTopTitle.text = self.TopTitle.uppercased()
        
        if #available(iOS 11.0, *) {
            tblVw.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tblVw.delegate = self
        tblVw.dataSource = self
        
        if !self.isFromSection && !self.isFromAmenities {
            if self.isCategory {
                self.FirebaseDataArr = self.appDelegate.FirebaseAllDataArr.filter({ $0.type == self.TopTitle })
                self.appDelegate.isSelectedCategory = self.TopTitle
                NotificationCenter.default.post(name: Notification.Name("allGrayMapDetails"), object: nil, userInfo: nil)
            }else{
                self.FirebaseDataArr = self.appDelegate.FirebaseAllDataArr.filter({ $0.Neighbourhood == self.TopTitle })
                self.appDelegate.isSelectedArea = self.TopTitle
                NotificationCenter.default.post(name: Notification.Name("allGrayMapDetailsByArea"), object: nil, userInfo: nil)
            }
        }else{
            if self.isFromAmenities {
                
                self.FirebaseDataArr.removeAll()
                
                var FirebaseDataArrLocal = [firebaseDataModel]()
                for item in self.ArrSelectedAmenities {
                    if item as! String == "Diaper Changing Area" {
                        if FirebaseDataArrLocal.count == 0{
                            FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.diaperChangingArea == "YES" })
                        }else{
                            FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.diaperChangingArea == "YES" })
                        }
                    }
                    if item as! String == "Cozy Feeding Area" {
                        if FirebaseDataArrLocal.count == 0{
                            FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.breastFeedingFriendly == "YES" })
                        }else{
                            FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.breastFeedingFriendly == "YES" })
                        }
                    }
                    if item as! String == "Play Area" {
                        if FirebaseDataArrLocal.count == 0{
                            FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.playArea == "YES" })
                        }else{
                            FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.playArea == "YES" })
                        }
                    }
                    if item as! String == "Kids' Menu" {
                        if FirebaseDataArrLocal.count == 0{
                            FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.kidsMenu == "YES" })
                        }else{
                            FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.kidsMenu == "YES" })
                        }
                    }
                }
                
                for model in FirebaseDataArrLocal {
                    let ArrData = self.FirebaseDataArr.filter { $0.titleName.lowercased().contains(model.titleName.lowercased()) }
                    if ArrData.count == 0 {
                        self.FirebaseDataArr.append(model)
                    }
                }
                
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
//                for item in self.ArrSelectedAmenities {
//                    if item as! String == "Diaper Changing Area" {
//                        var FirebaseDataArrLocal = [firebaseDataModel]()
//                        FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.diaperChangingArea == "YES" })
//                        for model in FirebaseDataArrLocal {
//                            
////                          self.FirebaseDataArr.append(model)
//                            let ArrData = self.FirebaseDataArr.filter { $0.titleName.lowercased().contains(model.titleName.lowercased()) }
//                            if ArrData.count == 0 {
//                                self.FirebaseDataArr.append(model)
//                            }
//                            
//                        }
//                    }
//                    else if item as! String == "Cozy Feeding Area" {
//                        var FirebaseDataArrLocal = [firebaseDataModel]()
//                        FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.breastFeedingFriendly == "YES" })
//                        for model in FirebaseDataArrLocal {
////                            self.FirebaseDataArr.append(model)
//                            let ArrData = self.FirebaseDataArr.filter { $0.titleName.lowercased().contains(model.titleName.lowercased()) }
//                            if ArrData.count == 0 {
//                                self.FirebaseDataArr.append(model)
//                            }
//                        }
//                    }
//                    else if item as! String == "Play Area" {
//                        var FirebaseDataArrLocal = [firebaseDataModel]()
//                        FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.playArea == "YES" })
//                        for model in FirebaseDataArrLocal {
////                            self.FirebaseDataArr.append(model)
//                            let ArrData = self.FirebaseDataArr.filter { $0.titleName.lowercased().contains(model.titleName.lowercased()) }
//                            if ArrData.count == 0 {
//                                self.FirebaseDataArr.append(model)
//                            }
//                        }
//                    }
//                    else if item as! String == "Kids' Menu" {
//                        var FirebaseDataArrLocal = [firebaseDataModel]()
//                        FirebaseDataArrLocal = self.appDelegate.FirebaseAllDataArr.filter({ $0.kidsMenu == "YES" })
//                        for model in FirebaseDataArrLocal {
////                            self.FirebaseDataArr.append(model)
//                            let ArrData = self.FirebaseDataArr.filter { $0.titleName.lowercased().contains(model.titleName.lowercased()) }
//                            if ArrData.count == 0 {
//                                self.FirebaseDataArr.append(model)
//                            }
//                        }
//                    }
//                }
                
                self.appDelegate.ArrSelectedAmenities = self.ArrSelectedAmenities
                NotificationCenter.default.post(name: Notification.Name("allGrayMapDataByAmenities"), object: nil, userInfo: nil)

            }else{
                self.FirebaseDataArr = self.appDelegate.FirebaseAllDataArr.filter({ $0.cityName == self.TopTitle })
                self.appDelegate.isSelectedSection = self.TopTitle
                NotificationCenter.default.post(name: Notification.Name("allGrayMapDetailsBySection"), object: nil, userInfo: nil)
            }
        }
        
        self.tblVw.reloadData()
        self.setHeaderShadow(opacity: 0.0)
    }

    @IBAction func dismissAction() {
        NotificationCenter.default.post(name: Notification.Name("allRedMapDetails"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("NormalMapDetails"), object: nil, userInfo: nil)
        sheetCoordinator?.removeSheetChild(item: self)
    }
    
    @objc func BackCalledArea(notfication: Notification) {
        NotificationCenter.default.post(name: Notification.Name("allRedMapDetails"), object: nil, userInfo: nil)
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

extension AreaCategoryDetailsVC: Draggable{
    func draggableView() -> UIScrollView? {
        return tblVw
    }
}

extension AreaCategoryDetailsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.FirebaseDataArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let acell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AreaCategoryDetailsCell
        let model = self.FirebaseDataArr[indexPath.row]
        acell.lblName.text = model.titleName.uppercased()
        
        if self.appDelegate.strCity == "Mommydata" {
            if model.type == "Community Centre" {
                acell.imgVw.image = UIImage.init(named: BlueMarkerNormal)
            }else if model.type == "Family Place" {
                acell.imgVw.image = UIImage.init(named: PinkMarkerNormal)
            }else if model.type == "Neighbourhood House" || model.type == "Community Services" {
                acell.imgVw.image = UIImage.init(named: LightBlueMarkerNormal)
            }else if model.type == "Public Library" {
                acell.imgVw.image = UIImage.init(named: PurpleMarkerNormal)
            }else if model.type == "Restaurant" || model.type == "Retail" || model.type == "Restaurants & Retail" || model.type == "Restaurants and Retail" {
                acell.imgVw.image = UIImage.init(named: WhiteMarkerNormal)
            }else if model.type == "Health Centre" {
                acell.imgVw.image = UIImage.init(named: HelthMarkerNormal)
            }
        }else{
            if model.type == "Arts and Nature"  {
                acell.imgVw.image = UIImage.init(named: HelthMarkerNormal)
            }else if model.type == "Community Services" {
                acell.imgVw.image = UIImage.init(named: LightBlueMarkerNormal)
            }else if model.type == "Public Library" {
                acell.imgVw.image = UIImage.init(named: BlueMarkerNormal)
            }else if model.type == "Restaurant" || model.type == "Retail" || model.type == "Restaurants & Retail" || model.type == "Restaurants and Retail" {
                acell.imgVw.image = UIImage.init(named: PurpleMarkerNormal)
            }else{
                acell.imgVw.image = UIImage.init(named: LightBlueMarkerNormal)
            }
        }

        return acell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tblVw.deselectRow(at: indexPath, animated: true)
        self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
        let model = self.FirebaseDataArr[indexPath.row]
        self.FilterByDetailsClosure!(model.titleName)
        let vc = MainStory.instantiateViewController(withIdentifier: "SpecificItemDetailsVC") as! SpecificItemDetailsVC
        vc.sheetCoordinator = self.sheetCoordinator
        vc.FirebaseDataArr = model
        vc.TopTitle = model.titleName
        if sheetCoordinator?.usesNavigationController ?? false {
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            sheetCoordinator?.addSheetChild(vc)
        }

    }
}

class AreaCategoryDetailsCell: UITableViewCell {
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var imgVw : UIImageView!
}
