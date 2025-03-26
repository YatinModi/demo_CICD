//
//  MapDetailVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 02/10/24.
//

import UIKit
import UBottomSheet

class MapDetailVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vwFooterVw: UIView!
    @IBOutlet weak var vwSubmitFooter: UIView!
    @IBOutlet weak var lblTopCityName : UILabel!
    
    @IBOutlet weak var lblMommyMapLoc : UILabel!
    
    @IBOutlet weak var vwHeaderTitle : UIView!
    @IBOutlet weak var vwHeaderTitleHeightConst : NSLayoutConstraint!

    var sheetCoordinator: UBottomSheetCoordinator?
    @IBOutlet weak var vwSegmentControl : SSSegmentedControl!
    @IBOutlet weak var vwTopHeader: UIView!

    var FirebaseDataArr = [firebaseDataModel]()
    var isArea = true
    var FilterClosure: ((_ strName: String) -> ())?

    var SectionArr = NSMutableArray()
    var SubTitleDataArr = NSMutableArray()
    
    var ArrAmenities : NSMutableArray = ["Diaper Changing Area","Cozy Feeding Area","Play Area","Kids' Menu"]
    var ArrSelectedAmenities : NSMutableArray = []
    var isSelectedAmenities = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ReloadMapDeta(notfication:)), name: Notification.Name("ReloadMapDetailsData"), object: nil)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        self.SetupUI()
    }
    
    @objc func ReloadMapDeta(notfication: Notification) {
        
        self.FirebaseDataArr = self.appDelegate.FirebaseAllDataArr

        self.SectionArr.removeAllObjects()
        self.SubTitleDataArr.removeAllObjects()
        for model in self.FirebaseDataArr {
            if !self.SectionArr.contains(model.cityName!) {
                self.SectionArr.add(model.cityName!)
            }
        }
//        self.SectionArr.add("Vancouver ")

        for sectionTitle in self.SectionArr {
            let subTitle = self.FirebaseDataArr.filter { $0.cityName == sectionTitle as? String }
            var subTitleNew =  [firebaseDataModel]()
            for model in subTitle {
                let ArrData = subTitleNew.filter { $0.Neighbourhood.replacingOccurrences(of: " ", with: "").contains(model.Neighbourhood.replacingOccurrences(of: " ", with: "")) }
                if ArrData.count == 0 {
                    subTitleNew.append(model)
                }
            }
            
            if self.appDelegate.strCity == "SantaFeMommyMap" {
                let sortedItems = subTitleNew.sorted { $0.titleName.lowercased() < $1.titleName.lowercased() }
                self.SubTitleDataArr.add(sortedItems)
            }else{
                let sortedItems = subTitleNew.sorted { $0.Neighbourhood.lowercased() < $1.Neighbourhood.lowercased() }
                self.SubTitleDataArr.add(sortedItems)
            }
        }
        print(self.SubTitleDataArr)

        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheetCoordinator?.startTracking(item: self)
    }
    
    func SetupUI() {
        
        let attributedString = NSMutableAttributedString(string: self.lblMommyMapLoc.text!)
        attributedString.addAttribute(.kern, value: 2.0, range: NSRange(location: 0, length: attributedString.length))
        self.lblMommyMapLoc.attributedText = attributedString

        if self.appDelegate.strCity == "Mommydata" {
            self.lblTopCityName.text = "GREATER VANCOUVER"
        }else{
            self.lblTopCityName.text = "SANTA FE"
        }
        
        self.vwSubmitFooter.isHidden = true
        self.vwFooterVw.frame.size.height = 140
        self.vwHeaderTitle.isHidden = true
        self.vwHeaderTitleHeightConst.constant = 0
        self.vwSegmentControl.didTapSegment = { index in
            print(index)
            self.vwHeaderTitle.isHidden = true
            self.vwHeaderTitleHeightConst.constant = 0
            if self.appDelegate.FirebaseAllDataArr.count == 0 { return }
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            self.isArea = index == 0 ? true : false
            if index == 0 {
                self.vwSubmitFooter.isHidden = true
                self.vwFooterVw.frame.size.height = 140
                self.isSelectedAmenities = false
                self.FirebaseDataArr = self.appDelegate.FirebaseAllDataArr
                
                self.SectionArr.removeAllObjects()
                self.SubTitleDataArr.removeAllObjects()
                for model in self.FirebaseDataArr {
                    if !self.SectionArr.contains(model.cityName!) {
                        self.SectionArr.add(model.cityName!)
                    }
                }
//                self.SectionArr.add("Vancouver ")

                for sectionTitle in self.SectionArr {
                    let subTitle = self.FirebaseDataArr.filter { $0.cityName == sectionTitle as? String }
                    var subTitleNew =  [firebaseDataModel]()
                    for model in subTitle {
                        let ArrData = subTitleNew.filter { $0.Neighbourhood.replacingOccurrences(of: " ", with: "").contains(model.Neighbourhood.replacingOccurrences(of: " ", with: "")) }
                        if ArrData.count == 0 {
                            subTitleNew.append(model)
                        }
                    }
                    
                    if self.appDelegate.strCity == "SantaFeMommyMap" {
                        let sortedItems = subTitleNew.sorted { $0.titleName.lowercased() < $1.titleName.lowercased() }
                        self.SubTitleDataArr.add(sortedItems)
                    }else{
                        let sortedItems = subTitleNew.sorted { $0.Neighbourhood.lowercased() < $1.Neighbourhood.lowercased() }
                        self.SubTitleDataArr.add(sortedItems)
                    }
                }
                self.tableView.reloadData()

            }else if index == 1 {
                self.vwSubmitFooter.isHidden = true
                self.vwFooterVw.frame.size.height = 140
                self.isSelectedAmenities = false
                self.FirebaseDataArr.removeAll()
                for model in self.appDelegate.FirebaseAllDataArr {
                    if !self.FirebaseDataArr.contains(where: { $0.type == model.type }) {
                        self.FirebaseDataArr.append(model)
                    }
                }
                self.moveCategoryByName("Family Place", to: 0)
                self.moveCategoryByName("Health Centre", to: 1)
                self.moveCategoryByName("Neighbourhood House", to: 2)
                self.moveCategoryByName("Community Centre", to: 3)
                self.moveCategoryByName("Public Library", to: 4)

            }else if index == 2 {
                self.isSelectedAmenities = true
                self.vwSubmitFooter.isHidden = false
                self.vwFooterVw.frame.size.height = 200
                self.vwHeaderTitle.isHidden = false
                self.vwHeaderTitleHeightConst.constant = 60
            }
            self.tableView.reloadData()
            self.sheetCoordinator!.setPosition(self.sheetCoordinator!.minSheetPosition!, animated: true)
        }
    }
    
    func moveCategoryByName(_ name: String, to newIndex: Int) {
        if let currentIndex = FirebaseDataArr.firstIndex(where: { $0.type == name }),
           currentIndex != newIndex,
           FirebaseDataArr.indices.contains(newIndex) {
            let person = FirebaseDataArr.remove(at: currentIndex)
            FirebaseDataArr.insert(person, at: newIndex)
        }
    }

}

extension MapDetailVC: Draggable{
    func draggableView() -> UIScrollView? {
        return tableView
    }
}

//Mark:- UIButton Action
extension MapDetailVC {
    
    @IBAction func btnSubmitClick(_ sender: UIButton) {
        if self.ArrSelectedAmenities.count == 0 {
            self.view.makeToast("Must select one Amenities")
            return
        }
        self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
        let vc = MainStory.instantiateViewController(withIdentifier: "AreaCategoryDetailsVC") as! AreaCategoryDetailsVC
        vc.sheetCoordinator = self.sheetCoordinator
        self.FilterClosure!("isBack")
        vc.FilterByDetailsClosure = {(strName: String) -> () in
            self.FilterClosure!(strName)
        }
        vc.isFromAmenities = true
        vc.ArrSelectedAmenities = self.ArrSelectedAmenities
        vc.TopTitle = self.ArrSelectedAmenities.componentsJoined(by: ",")
        if sheetCoordinator?.usesNavigationController ?? false {
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            sheetCoordinator?.addSheetChild(vc)
        }
    }
    
    @IBAction func btnChangeCityClick(_ sender: UIButton) {
        let vc = MainStory.instantiateViewController(withIdentifier: "CitySelectionVC") as! CitySelectionVC
        vc.modalPresentationStyle = .fullScreen
        vc.isDismiss = true
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func btnEventHeaderClick(_ sender: UIButton) {
        if let url = URL(string: "https://www.instagram.com/mommymap.app?igsh=OHN0bHY0cmtla2li") {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func btnAboutClick(_ sender: UIButton) {
//        self.FilterClosure!("isBack")
        let vc = MainStory.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
//        vc.sheetCoordinator = self.sheetCoordinator
//        if sheetCoordinator?.usesNavigationController ?? false {
        self.navigationController?.pushViewController(vc, animated: false)
//        }else{
//            sheetCoordinator?.addSheetChild(vc)
//        }
    }
    @IBAction func btnPrivacyClick(_ sender: UIButton) {
        self.FilterClosure!("isBack")
        let vc = MainStory.instantiateViewController(withIdentifier: "TosVC") as! TosVC
        vc.sheetCoordinator = self.sheetCoordinator
        vc.TopTitle = "Privacy"
        vc.strUrl = "https://docs.google.com/document/u/0/d/1U_io7EZGgtGpeF29uH-FIFW4bCh1U9cZvc8ii8D7G2M/mobilebasic" //"https://nycvintagemap.com/privacy" //"https://docs.google.com/document/d/1U_io7EZGgtGpeF29uH-FIFW4bCh1U9cZvc8ii8D7G2M/edit?tab=t.0" //"https://nycvintagemap.com/privacy"
        if sheetCoordinator?.usesNavigationController ?? false {
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            sheetCoordinator?.addSheetChild(vc)
        }
    }
    @IBAction func btnTermsClick(_ sender: UIButton) {
        self.FilterClosure!("isBack")
        let vc = MainStory.instantiateViewController(withIdentifier: "TosVC") as! TosVC
        vc.sheetCoordinator = self.sheetCoordinator
        vc.TopTitle = "Terms"
        vc.strUrl = "https://docs.google.com/document/d/1htE617pPnqRqTLRM7DMu4Q684DG_C3yEdYTCW6G4_j8/mobilebasic" //"https://nycvintagemap.com/terms"
        if sheetCoordinator?.usesNavigationController ?? false {
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            sheetCoordinator?.addSheetChild(vc)
        }
    }
    @IBAction func btnGemClick(_ sender: UIButton) {
        if let url = URL(string: "https://gem.app/") {
            UIApplication.shared.open(url)
        }
    }
}

//Mark:- UITableview Delegate
extension MapDetailVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isArea ? self.SectionArr.count : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSelectedAmenities {
            return self.ArrAmenities.count
        }else{
            if self.isArea {
                if let myArray = self.SubTitleDataArr.object(at: section) as? [firebaseDataModel] {
                    return myArray.count
                }
                return 0
            }else{
                return self.FirebaseDataArr.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let acell = tableView.dequeueReusableCell(withIdentifier: "MapAreaCell", for: indexPath) as! MapAreaCell
        
        if self.isSelectedAmenities {
            acell.selectionStyle = .none
            let strTitle = self.ArrAmenities[indexPath.row] as? String ?? ""
            acell.lblAreaName.text = strTitle.uppercased()
            acell.imgVwWidthConst.constant = 0
            acell.imgVwCheckboxWidthConst.constant = 20
            acell.lblAreaNameLeadingConst.constant = 10
            acell.imgVwCheckbox.image = self.ArrSelectedAmenities.contains(strTitle) ? #imageLiteral(resourceName: "ic_CheckboxSelected") : #imageLiteral(resourceName: "ic_Checkbox")
        }else{
            acell.selectionStyle = .default
            acell.imgVwCheckboxWidthConst.constant = 0
            if self.isArea {
                let myArray = self.SubTitleDataArr.object(at: indexPath.section) as! [firebaseDataModel]
                let model = myArray[indexPath.row]
                
                if self.appDelegate.strCity == "SantaFeMommyMap" {
                    acell.lblAreaName.text = (self.isArea ? model.titleName : model.type).uppercased()
                }else{
                    acell.lblAreaName.text = (self.isArea ? model.Neighbourhood : model.type).uppercased()
                }
                
                acell.lblAreaNameLeadingConst.constant = 15 //self.isArea ? 0 : 10
                acell.imgVwWidthConst.constant = self.isArea ? 0 : 20
            }else{
                let model = self.FirebaseDataArr[indexPath.row]
                acell.lblAreaName.text = (self.isArea ? model.Neighbourhood : model.type)?.uppercased()
                acell.lblAreaNameLeadingConst.constant = self.isArea ? 0 : 10
                acell.imgVwWidthConst.constant = self.isArea ? 0 : 20
                
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
                    }else{
                        acell.imgVw.image = UIImage.init(named: BlueMarkerNormal)
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
            }
        }
        
        return acell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isArea {
            let myArray = self.SubTitleDataArr.object(at: indexPath.section) as! [firebaseDataModel]
            let model = myArray[indexPath.row]
            if self.appDelegate.strCity == "SantaFeMommyMap" {
                return model.titleName != "" ? 45.0 : 0
            }else{
                return model.Neighbourhood != "" ? 45.0 : 0
            }
        }else{
            return 45.0
        }
    }
    
    // Custom section header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        let titleLabel = UILabel()
        titleLabel.text = (self.SectionArr[section] as? String ?? "").uppercased()
        titleLabel.textColor = .black
        titleLabel.font = UIFont.init(name: "Comfortaa", size: 22) //.systemFont(ofSize: 25.0, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Add tap gesture recognizer to the header view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSectionTap(_:)))
        headerView.tag = section // Set the section index as the tag
        headerView.addGestureRecognizer(tapGesture)

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.isArea ? 50 : .leastNormalMagnitude
    }
    
    @objc func handleSectionTap(_ sender: UITapGestureRecognizer) {
        if let section = sender.view?.tag, let headerView = sender.view {
            
            headerView.backgroundColor = .systemGray3
            UIView.animate(withDuration: 0.5, animations: {
                headerView.backgroundColor = .clear
            }) { (_) in
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let SectionName = self.SectionArr[section] as? String ?? ""
                print(SectionName)
                self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
                let vc = MainStory.instantiateViewController(withIdentifier: "AreaCategoryDetailsVC") as! AreaCategoryDetailsVC
                vc.sheetCoordinator = self.sheetCoordinator
                self.FilterClosure!("isBack")
                vc.FilterByDetailsClosure = {(strName: String) -> () in
                    self.FilterClosure!(strName)
                }
                vc.isFromSection = true
                vc.TopTitle = SectionName
                if self.sheetCoordinator?.usesNavigationController ?? false {
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.sheetCoordinator?.addSheetChild(vc)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if self.isSelectedAmenities {
            let strTitle = self.ArrAmenities[indexPath.row] as? String ?? ""
            if self.ArrSelectedAmenities.contains(strTitle) {
                self.ArrSelectedAmenities.remove(strTitle)
            }else{
                self.ArrSelectedAmenities.add(strTitle)
            }
            self.tableView.reloadData()
        }else{
            
            if self.isArea {
                //            self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
                //            let model = self.FirebaseDataArr[indexPath.row]
                //            self.FilterClosure!(model.titleName)
                //            let vc = MainStory.instantiateViewController(withIdentifier: "SpecificItemDetailsVC") as! SpecificItemDetailsVC
                //            vc.sheetCoordinator = self.sheetCoordinator
                //            vc.FirebaseDataArr = model
                //            vc.TopTitle = self.isArea ? model.titleName : model.type
                //            if sheetCoordinator?.usesNavigationController ?? false {
                //                self.navigationController?.pushViewController(vc, animated: true)
                //            }else{
                //                sheetCoordinator?.addSheetChild(vc)
                //            }
                
                
                if self.appDelegate.strCity == "SantaFeMommyMap" {
                    
                    self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
                    let myArray = self.SubTitleDataArr.object(at: indexPath.section) as! [firebaseDataModel]
                    let model = myArray[indexPath.row]
                    self.FilterClosure!(model.titleName)
                    let vc = MainStory.instantiateViewController(withIdentifier: "SpecificItemDetailsVC") as! SpecificItemDetailsVC
                    vc.sheetCoordinator = self.sheetCoordinator
                    vc.FirebaseDataArr = model
                    vc.TopTitle = self.isArea ? model.titleName : model.type
                    if sheetCoordinator?.usesNavigationController ?? false {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        sheetCoordinator?.addSheetChild(vc)
                    }

                }else{
                    self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
                    let myArray = self.SubTitleDataArr.object(at: indexPath.section) as! [firebaseDataModel]
                    let model = myArray[indexPath.row]
                    let vc = MainStory.instantiateViewController(withIdentifier: "AreaCategoryDetailsVC") as! AreaCategoryDetailsVC
                    vc.sheetCoordinator = self.sheetCoordinator
                    self.FilterClosure!("isBack")
                    vc.FilterByDetailsClosure = {(strName: String) -> () in
                        self.FilterClosure!(strName)
                    }
                    vc.isCategory = !self.isArea
                    vc.TopTitle = model.Neighbourhood
                    if sheetCoordinator?.usesNavigationController ?? false {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        sheetCoordinator?.addSheetChild(vc)
                    }
                }
                
                
            }else{
                self.sheetCoordinator!.setPosition(self.sheetCoordinator!.maxSheetPosition! - 100, animated: true)
                let model = self.FirebaseDataArr[indexPath.row]
                let vc = MainStory.instantiateViewController(withIdentifier: "AreaCategoryDetailsVC") as! AreaCategoryDetailsVC
                vc.sheetCoordinator = self.sheetCoordinator
                self.FilterClosure!("isBack")
                vc.FilterByDetailsClosure = {(strName: String) -> () in
                    self.FilterClosure!(strName)
                }
                vc.isCategory = !self.isArea
                vc.TopTitle = self.isArea ? model.titleName : model.type
                if sheetCoordinator?.usesNavigationController ?? false {
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    sheetCoordinator?.addSheetChild(vc)
                }
            }
        }
    }

}

class MapAreaCell: UITableViewCell {
    @IBOutlet weak var lblAreaName : UILabel!
    @IBOutlet weak var imgVw : UIImageView!
    @IBOutlet weak var lblAreaNameLeadingConst : NSLayoutConstraint!
    @IBOutlet weak var imgVwWidthConst : NSLayoutConstraint!
    @IBOutlet weak var imgVwCheckboxWidthConst : NSLayoutConstraint!
    @IBOutlet weak var imgVwCheckbox : UIImageView!
}
