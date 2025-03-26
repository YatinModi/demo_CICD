//
//  HomeVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 26/09/24.
//

import UIKit
import MapboxMaps
import FirebaseDatabase
import CoreLocation
import UBottomSheet

class HomeVC: UIViewController {
    
    @IBOutlet weak var mpView : UIView!
    @IBOutlet weak var VwSearch : UIView!
    @IBOutlet weak var VwSearchTopConst : NSLayoutConstraint!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var btnBack : UIButton!
    @IBOutlet weak var btnCurrentLocation : UIButton!
//    @IBOutlet weak var btnCurrentLocationTopConst : NSLayoutConstraint!
    @IBOutlet weak var btnGoBackNYC : UIButton!

    private let locationManager = CLLocationManager()
    var mapView: MapView!
    var pointAnnotationManager: PointAnnotationManager!
    var annotations: [PointAnnotation] = []
    var SelectedIndex: Int = -1
    var isGraySelectedMarker = "" //false
    var currentlySelectedAnnotation: PointAnnotation?
    
    var titleLabel: UILabel!
    var FirebaseDataArr = [firebaseDataModel]()
    var isSearchBarAnimation = false
    var isAnimating = false
    
    var FirstCoordinate = CLLocationCoordinate2D()
    var userCurrentCoordinate: CLLocationCoordinate2D? // Optional CLLocationCoordinate2D
    var animationDuration = 0.0 //0.1
        
    var sheetCoordinator: UBottomSheetCoordinator!
    var sheetVC: DraggableItem!
    var useNavController = false
    var dataSource: UBottomSheetCoordinatorDataSource?
    var backView: PassThroughView?

    var isTappedCurrentLocation = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.NormalMapDeta(notfication:)), name: Notification.Name("NormalMapDetails"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allGrayMapData(notfication:)), name: Notification.Name("allGrayMapDetails"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allGrayMapDataByArea(notfication:)), name: Notification.Name("allGrayMapDetailsByArea"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allGrayMapDataBySection(notfication:)), name: Notification.Name("allGrayMapDetailsBySection"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allGrayMapDataByAmenities(notfication:)), name: Notification.Name("allGrayMapDataByAmenities"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.allRedMapData(notfication:)), name: Notification.Name("allRedMapDetails"), object: nil)
        
        //self.btnCurrentLocationTopConst.constant = 65

        self.VwSearch.SetSadow(view: self.VwSearch)
        self.btnBack.SetSadow(view: self.btnBack)
//        self.vwMainDetailsBottom.SetSadow(view: self.vwMainDetailsBottom)
        self.btnCurrentLocation.SetSadow(view: self.btnCurrentLocation)
        self.btnCurrentLocation.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        self.SetupUI()
        
        var Lat = 0.0
        var Long = 0.0
        if self.appDelegate.strCity == "Mommydata" {
            Lat = 49.2741381
            Long = -123.0703439
        }else{
            Lat = 35.6885888
            Long = -105.9367428
        }
//        Lat = 49.1915359
//        Long = -123.0745391

        let cameraOptions = CameraOptions(center:CLLocationCoordinate2D(latitude: Lat, longitude: Long),zoom: 8, bearing: 0, pitch: 0)
        let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)
        self.mapView = MapView(frame: self.mpView.bounds, mapInitOptions: mapInitOptions)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.mapboxMap.mapStyle = .standard
        self.mapView.mapboxMap.loadStyle(.streets)
        self.mapView.ornaments.options.scaleBar.visibility = .hidden
        self.mapView.ornaments.options.compass.visibility = .hidden
        self.mapView.ornaments.options.attributionButton.position = .bottomLeft
        self.mapView.ornaments.options.attributionButton.margins = CGPoint(x: 90, y: 40)
        self.mapView.ornaments.options.logo.margins = CGPoint(x: 10, y: 40)

        self.mpView.addSubview(mapView)
        try! self.mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(
            maxZoom: 18.0, minZoom: 3.0 ))
        self.mapView.isHidden = true
        
        if Reachabilty.isConnectedToNetwork() {
            self.GetFirebaseData()
        }else{
            self.showMyAlert(myMessage: strNetworkMSG)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isSearchBarAnimation {
            self.isSearchBarAnimation = false
            let xPosition = VwSearch.frame.origin.x
            let yPosition = VwSearch.frame.origin.y - 6
            let width = VwSearch.frame.size.width
            let height = VwSearch.frame.size.height
            UIView.animate(withDuration: 0.2, animations: {
                self.VwSearch.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
            })
        }
        
    }

    func SetupUI() {

    }
    
    @objc func allGrayMapDataByAmenities(notfication: Notification) {
        
        var AnimateCoordinate = [CLLocationCoordinate2D]()

        self.FirebaseDataArr.forEach { $0.isGrayMarker = true }
        for model in FirebaseDataArr {
            for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue, name == model.titleName {
                    self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: GrayMarker)!, name: GrayMarker)
                }
            }
        }
        
        var FirebaseDataArrLocal = [firebaseDataModel]()
        for item in self.appDelegate.ArrSelectedAmenities {
            if item as! String == "Diaper Changing Area" {
                if FirebaseDataArrLocal.count == 0{
                    FirebaseDataArrLocal = self.FirebaseDataArr.filter({ $0.diaperChangingArea == "YES" })
                }else{
                    FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.diaperChangingArea == "YES" })
                }
            }
            if item as! String == "Cozy Feeding Area" {
                if FirebaseDataArrLocal.count == 0{
                    FirebaseDataArrLocal = self.FirebaseDataArr.filter({ $0.breastFeedingFriendly == "YES" })
                }else{
                    FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.breastFeedingFriendly == "YES" })
                }
            }
            if item as! String == "Play Area" {
                if FirebaseDataArrLocal.count == 0{
                    FirebaseDataArrLocal = self.FirebaseDataArr.filter({ $0.playArea == "YES" })
                }else{
                    FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.playArea == "YES" })
                }
            }
            if item as! String == "Kids' Menu" {
                if FirebaseDataArrLocal.count == 0{
                    FirebaseDataArrLocal = self.FirebaseDataArr.filter({ $0.kidsMenu == "YES" })
                }else{
                    FirebaseDataArrLocal = FirebaseDataArrLocal.filter({ $0.kidsMenu == "YES" })
                }
            }
        }
        
        for model in FirebaseDataArrLocal {
            if let index = self.FirebaseDataArr.firstIndex(where: { $0.titleName.lowercased() == model.titleName.lowercased() }) {
//                print("Index found: \(index)")
                self.FirebaseDataArr[index].isGrayMarker = false
                let coordinate = model.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                let Lat = Double(coordinate[0])!
                let Long = Double(coordinate[1])!
                AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
            }
        }
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//        for item in self.appDelegate.ArrSelectedAmenities {
//            if item as! String == "Diaper Changing Area" {
//                self.FirebaseDataArr.forEach { item in
//                    if item.diaperChangingArea == "YES" {
//                        item.isGrayMarker = false
////                        if AnimateCoordinate.latitude == 0.0 {
//                            let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
//                            let Lat = Double(coordinate[0])!
//                            let Long = Double(coordinate[1])!
//                            AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
////                        }
//                    }
//                }
//            }
//            else if item as! String == "Cozy Feeding Area" {
//                self.FirebaseDataArr.forEach { item in
//                    if item.breastFeedingFriendly == "YES" {
//                        item.isGrayMarker = false
////                        if AnimateCoordinate.latitude == 0.0 {
//                            let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
//                            let Lat = Double(coordinate[0])!
//                            let Long = Double(coordinate[1])!
//                            AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
////                        }
//                    }
//                }
//            }
//            else if item as! String == "Play Area" {
//                self.FirebaseDataArr.forEach { item in
//                    if item.playArea == "YES" {
//                        item.isGrayMarker = false
////                        if AnimateCoordinate.latitude == 0.0 {
//                            let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
//                            let Lat = Double(coordinate[0])!
//                            let Long = Double(coordinate[1])!
//                            AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
////                        }
//                    }
//                }
//            }
//            else if item as! String == "Kids' Menu" {
//                self.FirebaseDataArr.forEach { item in
//                    if item.kidsMenu == "YES" {
//                        item.isGrayMarker = false
////                        if AnimateCoordinate.latitude == 0.0 {
//                            let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
//                            let Lat = Double(coordinate[0])!
//                            let Long = Double(coordinate[1])!
//                            AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
////                        }
//                    }
//                }
//            }
//        }
                
        let CategoryWiseModel1 = self.FirebaseDataArr.filter({$0.isGrayMarker == false} )
        if CategoryWiseModel1.count != 0 {
            for model1 in CategoryWiseModel1 {
                for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue, name == model1.titleName {
                        
                        var strIconImage1 = ""
                        if self.appDelegate.strCity == "Mommydata" {
                            if model1.type == "Community Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: name)
                                strIconImage1 = BlueMarkerNormal
                            }else if model1.type == "Family Place" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PinkMarkerNormal)!, name: name)
                                strIconImage1 = PinkMarkerNormal
                            }else if model1.type == "Neighbourhood House" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: name)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model1.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: name)
                                strIconImage1 = PurpleMarkerNormal
                            }else if model1.type == "Restaurant" || model1.type == "Retail" || model1.type == "Restaurants & Retail" || model1.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: WhiteMarkerNormal)!, name: name)
                                strIconImage1 = WhiteMarkerNormal
                            }else if model1.type == "Health Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: name)
                                strIconImage1 = HelthMarkerNormal
                            }
                        }else{
                            if model1.type == "Arts and Nature"  {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = HelthMarkerNormal
                            }else if model1.type == "Community Services" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model1.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = BlueMarkerNormal
                            }else if model1.type == "Restaurant" || model1.type == "Retail" || model1.type == "Restaurants & Retail" || model1.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = PurpleMarkerNormal
                            }
                        }
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(strIconImage1)]
                        self.pointAnnotationManager.annotations[index].customData = customData

                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
//            self.zoomToMarker(self.FirstCoordinate, ZoomScale: 9.0, isCheckCondition: true)
            if AnimateCoordinate.count == 1 {
                self.zoomToMarker(AnimateCoordinate[0], ZoomScale: 11.0, isCheckCondition: true)
            }else{
                self.zoomToMarkerByFilter(AnimateCoordinate, ZoomScale: 11.0, isCheckCondition: true)
            }
        }
    }
    
    @objc func allGrayMapDataBySection(notfication: Notification) {
        
        var AnimateCoordinate = [CLLocationCoordinate2D]()

        self.FirebaseDataArr.forEach { $0.isGrayMarker = true }
        for model in FirebaseDataArr {
            for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue, name == model.titleName {
                    self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: GrayMarker)!, name: GrayMarker)
                }
            }
        }
        self.FirebaseDataArr.forEach { item in
            if item.cityName == self.appDelegate.isSelectedSection {
                item.isGrayMarker = false
//                if AnimateCoordinate.latitude == 0.0 {
                    let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                    let Lat = Double(coordinate[0])!
                    let Long = Double(coordinate[1])!
//                    AnimateCoordinate = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
                    AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
//                }
            }
        }
        let CategoryWiseModel1 = self.FirebaseDataArr.filter({$0.isGrayMarker == false} )
        if CategoryWiseModel1.count != 0 {
            for model1 in CategoryWiseModel1 {
                for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue, name == model1.titleName {
                        
                        var strIconImage1 = ""
                        if self.appDelegate.strCity == "Mommydata" {
                            if model1.type == "Community Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: name)
                                strIconImage1 = BlueMarkerNormal
                            }else if model1.type == "Family Place" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PinkMarkerNormal)!, name: name)
                                strIconImage1 = PinkMarkerNormal
                            }else if model1.type == "Neighbourhood House" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: name)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model1.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: name)
                                strIconImage1 = PurpleMarkerNormal
                            }else if model1.type == "Restaurant" || model1.type == "Retail" || model1.type == "Restaurants & Retail" || model1.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: WhiteMarkerNormal)!, name: name)
                                strIconImage1 = WhiteMarkerNormal
                            }else if model1.type == "Health Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: name)
                                strIconImage1 = HelthMarkerNormal
                            }
                        }else{
                            if model1.type == "Arts and Nature"  {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = HelthMarkerNormal
                            }else if model1.type == "Community Services" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model1.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = BlueMarkerNormal
                            }else if model1.type == "Restaurant" || model1.type == "Retail" || model1.type == "Restaurants & Retail" || model1.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = PurpleMarkerNormal
                            }
                        }
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(strIconImage1)]
                        self.pointAnnotationManager.annotations[index].customData = customData

                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            if AnimateCoordinate.count == 1 {
                self.zoomToMarker(AnimateCoordinate[0], ZoomScale: 11.0, isCheckCondition: true)
            }else{
                self.zoomToMarkerByFilter(AnimateCoordinate, ZoomScale: 9.0, isCheckCondition: true)
            }
        }
    }
    
    @objc func allGrayMapDataByArea(notfication: Notification) {
        
        var AnimateCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        self.FirebaseDataArr.forEach { $0.isGrayMarker = true }
        for model in FirebaseDataArr {
            for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue, name == model.titleName {
                    self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: GrayMarker)!, name: GrayMarker)
                }
            }
        }
        self.FirebaseDataArr.forEach { item in
            if item.Neighbourhood == self.appDelegate.isSelectedArea {
                item.isGrayMarker = false
                if AnimateCoordinate.latitude == 0.0 {
                    let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                    let Lat = Double(coordinate[0])!
                    let Long = Double(coordinate[1])!
                    AnimateCoordinate = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
                }
            }
        }
        let CategoryWiseModel1 = self.FirebaseDataArr.filter({$0.isGrayMarker == false} )
        if CategoryWiseModel1.count != 0 {
            for model1 in CategoryWiseModel1 {
                for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue, name == model1.titleName {
                        
                        var strIconImage1 = ""
                        if self.appDelegate.strCity == "Mommydata" {
                            if model1.type == "Community Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: name)
                                strIconImage1 = BlueMarkerNormal
                            }else if model1.type == "Family Place" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PinkMarkerNormal)!, name: name)
                                strIconImage1 = PinkMarkerNormal
                            }else if model1.type == "Neighbourhood House" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: name)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model1.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: name)
                                strIconImage1 = PurpleMarkerNormal
                            }else if model1.type == "Restaurant" || model1.type == "Retail" || model1.type == "Restaurants & Retail" || model1.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: WhiteMarkerNormal)!, name: name)
                                strIconImage1 = WhiteMarkerNormal
                            }else if model1.type == "Health Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: name)
                                strIconImage1 = HelthMarkerNormal
                            }
                        }else{
                            if model1.type == "Arts and Nature"  {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = HelthMarkerNormal
                            }else if model1.type == "Community Services" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model1.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = BlueMarkerNormal
                            }else if model1.type == "Restaurant" || model1.type == "Retail" || model1.type == "Restaurants & Retail" || model1.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: model1.titleName)
                                strIconImage1 = PurpleMarkerNormal
                            }
                        }
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(strIconImage1)]
                        self.pointAnnotationManager.annotations[index].customData = customData

                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
//            self.zoomToMarker(self.FirstCoordinate, ZoomScale: 9.0, isCheckCondition: true)
            self.zoomToMarker(AnimateCoordinate, ZoomScale: 11.0, isCheckCondition: true)
        }
    }
    
    @objc func allGrayMapData(notfication: Notification) {
//        self.FirebaseDataArr.forEach { item in
//            if item.type == self.appDelegate.isSelectedCategory {
//                item.isGrayMarker = false
//            } else {
//                item.isGrayMarker = true
//            }
//        }
        
        var AnimateCoordinate = [CLLocationCoordinate2D]()

        self.FirebaseDataArr.forEach { $0.isGrayMarker = true }
        for model in FirebaseDataArr {
            for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue, name == model.titleName {
                    self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: GrayMarker)!, name: GrayMarker)
                }
            }
        }
        
        self.FirebaseDataArr.forEach { item in
            if item.type == self.appDelegate.isSelectedCategory {
                item.isGrayMarker = false
                let coordinate = item.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                let Lat = Double(coordinate[0])!
                let Long = Double(coordinate[1])!
                AnimateCoordinate.append(CLLocationCoordinate2D(latitude: Lat, longitude: Long))
            }
        }
        let CategoryWiseModel1 = self.FirebaseDataArr.filter({$0.isGrayMarker == false} )
        if CategoryWiseModel1.count != 0 {
            for model1 in CategoryWiseModel1 {
                for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue, name == model1.titleName {
                        
                        var strIconImage1 = ""
                        if self.appDelegate.strCity == "Mommydata" {
                            if self.appDelegate.isSelectedCategory == "Community Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: name)
                                strIconImage1 = BlueMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Family Place" || self.appDelegate.isSelectedCategory == "Arts and Nature" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PinkMarkerNormal)!, name: name)
                                strIconImage1 = PinkMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Neighbourhood House" || self.appDelegate.isSelectedCategory == "Community Services" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: name)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: name)
                                strIconImage1 = PurpleMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Restaurant" || self.appDelegate.isSelectedCategory == "Retail" || self.appDelegate.isSelectedCategory == "Restaurants & Retail" || self.appDelegate.isSelectedCategory == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: WhiteMarkerNormal)!, name: name)
                                strIconImage1 = WhiteMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Health Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: name)
                                strIconImage1 = HelthMarkerNormal
                            }
                        }else{
                            if self.appDelegate.isSelectedCategory == "Arts and Nature"  {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: name)
                                strIconImage1 = HelthMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Community Services" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: name)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: name)
                                strIconImage1 = BlueMarkerNormal
                            }else if self.appDelegate.isSelectedCategory == "Restaurant" || self.appDelegate.isSelectedCategory == "Retail" || self.appDelegate.isSelectedCategory == "Restaurants & Retail" || self.appDelegate.isSelectedCategory == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: name)
                                strIconImage1 = PurpleMarkerNormal
                            }
                        }
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(strIconImage1)]
                        self.pointAnnotationManager.annotations[index].customData = customData

                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
//            self.zoomToMarker(self.FirstCoordinate, ZoomScale: 9.0, isCheckCondition: true)
            if AnimateCoordinate.count == 1 {
                self.zoomToMarker(AnimateCoordinate[0], ZoomScale: 11.0, isCheckCondition: true)
            }else{
                self.zoomToMarkerByFilter(AnimateCoordinate, ZoomScale: 9.0, isCheckCondition: true)
            }
        }
    }
    
    @objc func allRedMapData(notfication: Notification) {
        let CategoryWiseModel = self.FirebaseDataArr.filter({$0.isGrayMarker == true })
        if CategoryWiseModel.count != 0 {
            for model in CategoryWiseModel {
                for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue, name == model.titleName {
                        
//  self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: "Marker")!, name: "Marker")
                        var strIconImage1 = ""
                        if self.appDelegate.strCity == "Mommydata" {
                            if model.type == "Community Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: name)
                                strIconImage1 = BlueMarkerNormal
                            }else if model.type == "Family Place" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PinkMarkerNormal)!, name: name)
                                strIconImage1 = PinkMarkerNormal
                            }else if model.type == "Neighbourhood House" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: name)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: name)
                                strIconImage1 = PurpleMarkerNormal
                            }else if model.type == "Restaurant" || model.type == "Retail" || model.type == "Restaurants & Retail" || model.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: WhiteMarkerNormal)!, name: name)
                                strIconImage1 = WhiteMarkerNormal
                            }else if model.type == "Health Centre" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: name)
                                strIconImage1 = HelthMarkerNormal
                            }
                        }else{
                            if model.type == "Arts and Nature"  {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: HelthMarkerNormal)!, name: model.titleName)
                                strIconImage1 = HelthMarkerNormal
                            }else if model.type == "Community Services" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: model.titleName)
                                strIconImage1 = LightBlueMarkerNormal
                            }else if model.type == "Public Library" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: BlueMarkerNormal)!, name: model.titleName)
                                strIconImage1 = BlueMarkerNormal
                            }else if model.type == "Restaurant" || model.type == "Retail" || model.type == "Restaurants & Retail" || model.type == "Restaurants and Retail" {
                                self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: model.titleName)
                                strIconImage1 = PurpleMarkerNormal
                            }

                        }
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(strIconImage1)]
                        self.pointAnnotationManager.annotations[index].customData = customData

                    }
                }
            }
            self.appDelegate.isSelectedCategory = ""
            self.appDelegate.isSelectedArea = ""
            self.appDelegate.isSelectedSection = ""
            self.FirebaseDataArr.forEach { $0.isGrayMarker = false }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.zoomToMarker(self.FirstCoordinate, ZoomScale: 10.0, isCheckCondition: true)
        }
    }
    
    @objc func NormalMapDeta(notfication: Notification) {
        self.BackCalled()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        guard sheetCoordinator == nil else {return}
        sheetCoordinator = UBottomSheetCoordinator(parent: self,
                                                   delegate: self)
        let vc = MainStory.instantiateViewController(withIdentifier: "MapDetailVC") as! MapDetailVC
        vc.sheetCoordinator = sheetCoordinator
        vc.FilterClosure = {(strName: String) -> () in
            print(strName)
            if strName == "isBack" {
                self.btnBack.isHidden = false
                return
            }
//            let largeImage = UIImage(named: "BigMarket")
//            let Normal = UIImage(named: "Marker")
            if self.SelectedIndex != -1 {
//                self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: Normal!, name: "Marker")
                let StrIconName = self.isGraySelectedMarker.replacingOccurrences(of: "Big", with: "")
                self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: UIImage(named: StrIconName)!, name: StrIconName)
                if let nameValue = self.pointAnnotationManager.annotations[self.SelectedIndex].customData["name"],
                   case let .string(name) = nameValue {
                    let customData: JSONObject = ["name": .string(name), "iconImage": .string(StrIconName)]
                    self.pointAnnotationManager.annotations[self.SelectedIndex].customData = customData
                }
                self.SelectedIndex = -1
            }
            for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue, name == strName {
                    print(index)
                    self.SelectedIndex = index
                    
//    self.pointAnnotationManager.annotations[index].image = .init(image: largeImage!, name: "BigMarket")
                    if let iconName = annotation.customData["iconImage"],
                       case let .string(name) = iconName {
                        self.isGraySelectedMarker = "Big\(name)"
                        self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: "\(self.isGraySelectedMarker)")!, name: "\(self.isGraySelectedMarker)")
                    }
                    
                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue {
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(self.isGraySelectedMarker)]
                        self.pointAnnotationManager.annotations[index].customData = customData

                        self.showTitle(annotation: annotation, Title: name)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                        self.btnBack.isHidden = false
                        self.zoomToMarker(annotation.point.coordinates, ZoomScale: 11.0, isCheckCondition: true)
                    }
                }
            }
        }
        sheetCoordinator.addSheet(vc, to: self, didContainerCreate: { container in })
        
        NSLayoutConstraint.activate([
            self.btnCurrentLocation.bottomAnchor.constraint(equalTo: vc.view.topAnchor, constant: -15)
        ])

    }
    
}

extension HomeVC: UBottomSheetCoordinatorDelegate{
    
    private func addBackDimmingBackView(below container: UIView){
        backView = PassThroughView()
        self.view.insertSubview(backView!, belowSubview: container)
        backView!.translatesAutoresizingMaskIntoConstraints = false
        backView!.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        backView!.bottomAnchor.constraint(equalTo: container.topAnchor, constant: 10).isActive = true
        backView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        backView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }

    func bottomSheet(_ container: UIView?, didPresent state: SheetTranslationState) {
//        self.addBackDimmingBackView(below: container!)
        self.sheetCoordinator.addDropShadowIfNotExist()
        self.handleState(state, bottomSheetView: container!)
    }

    func bottomSheet(_ container: UIView?, didChange state: SheetTranslationState) {
        handleState(state, bottomSheetView: container!)
    }

    func bottomSheet(_ container: UIView?, finishTranslateWith extraAnimation: @escaping ((CGFloat) -> Void) -> Void) {
        extraAnimation({ percent in
            if percent == 100.0 {
                self.SearchVwAnimation(ZoomScale: 11.0)
            }else{
                self.SearchVwAnimation(ZoomScale: 0.0)
            }
            self.backView?.backgroundColor = UIColor.black.withAlphaComponent(percent/100 * 0.8)
        })
    }
    
    func handleState(_ state: SheetTranslationState, bottomSheetView: UIView){
        switch state {
        case .progressing(_, let percent):
            self.backView?.backgroundColor = UIColor.black.withAlphaComponent(percent/100 * 0.8)
            self.appDelegate.PercentageValue = percent
            NotificationCenter.default.post(name: Notification.Name("getPercentageValue"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("getPercentageValueArea"), object: nil, userInfo: nil)
        case .finished(_, let percent):
            self.backView?.backgroundColor = UIColor.black.withAlphaComponent(percent/100 * 0.8)
            self.appDelegate.PercentageValue = percent
            NotificationCenter.default.post(name: Notification.Name("getPercentageValue"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("getPercentageValueArea"), object: nil, userInfo: nil)
        default:
            break
        }
    }
    
}


// MARK: - CLLocationManagerDelegate
extension HomeVC: CLLocationManagerDelegate {
    
    private func setupLocation() {
        if self.userCurrentCoordinate != nil {
            self.locationManager.delegate = self
            if mapView != nil {
                self.mapView.location.options.puckType = .puck2D(
                    Puck2DConfiguration(topImage: UIImage(named: "ic_CurrentLocationDot"), bearingImage: nil, shadowImage: nil)
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                    self.zoomToEaseAnimation(self.userCurrentCoordinate!, ZoomScale: 14.0)
                }
            }
        }else{
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            if mapView != nil {
                let status = CLLocationManager.authorizationStatus()
                if status == .authorizedAlways || status == .authorizedWhenInUse {
                    self.mapView.location.options.puckType = .puck2D(
                        Puck2DConfiguration(topImage: UIImage(named: "ic_CurrentLocationDot"), bearingImage: nil, shadowImage: nil))
                }else if status == .denied {
                    let alertController = UIAlertController(title: "Need Permissions",message: "This app needs permission to use this feature. You can grant them in app settings.",preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "CANCEL", style: .default, handler: nil)
                    let openAction = UIAlertAction(title: "GOTO SETTINGS", style: .cancel) { (action) in
                        if let url = NSURL(string:UIApplication.openSettingsURLString) {
                            UIApplication.shared.openURL(url as URL)
                        }
                    }
                    alertController.addAction(openAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.delegate = self
            locationManager.startUpdatingLocation()
            mapView.location.options.puckType = .puck2D()
        case .denied, .restricted:
            print("Location access denied.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let userCoordinate = location.coordinate
        self.userCurrentCoordinate = location.coordinate
        self.locationManager.stopUpdatingLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
            if self.mapView != nil {
                self.zoomToEaseAnimation(userCoordinate, ZoomScale: 14.0)
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}

//Mark:- UIButton Action
extension HomeVC {
    @IBAction func btnGoBackNYC(_ sender: UIButton) {
        self.btnGoBackNYC.isHidden = true
        self.BackCalled()
    }
    @IBAction func btnBack(_ sender: UIButton) {
        self.BackCalled()
    }
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        if Reachabilty.isConnectedToNetwork() {
            self.isTappedCurrentLocation = true
            self.sheetCoordinator.setPosition(self.sheetCoordinator.maxSheetPosition!, animated: true)
            self.setupLocation()
        }else{
            self.showMyAlert(myMessage: strNetworkMSG)
        }
    }
}

//Mark:- UIButton Action
extension HomeVC {
    @IBAction func btnSearch(_ sender: UIButton) {
        self.isSearchBarAnimation = true
        let xPosition = VwSearch.frame.origin.x
        let yPosition = VwSearch.frame.origin.y + 6
        let width = VwSearch.frame.size.width
        let height = VwSearch.frame.size.height
        self.VwSearch.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let vc = MainStory.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        vc.SimpleClosure = {(strName: String) -> () in
            print(strName)
            
//            let largeImage = UIImage(named: "BigMarket")
//            let Normal = UIImage(named: "Marker")
            if self.SelectedIndex != -1 {
                
//                self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: Normal!, name: "Marker")
                let StrIconName = self.isGraySelectedMarker.replacingOccurrences(of: "Big", with: "")
                self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: UIImage(named: StrIconName)!, name: StrIconName)
                if let nameValue = self.pointAnnotationManager.annotations[self.SelectedIndex].customData["name"],
                   case let .string(name) = nameValue {
                    let customData: JSONObject = ["name": .string(name), "iconImage": .string(StrIconName)]
                    self.pointAnnotationManager.annotations[self.SelectedIndex].customData = customData
                }

                self.SelectedIndex = -1
            }

            for (index, annotation) in self.pointAnnotationManager.annotations.enumerated() {
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue, name == strName {
                    print(index)
                    self.SelectedIndex = index
                    
//                    self.pointAnnotationManager.annotations[index].image = .init(image: largeImage!, name: "BigMarket")
                    if let iconName = annotation.customData["iconImage"],
                       case let .string(name) = iconName {
                        self.isGraySelectedMarker = "Big\(name)"
                        self.pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: "\(self.isGraySelectedMarker)")!, name: "\(self.isGraySelectedMarker)")
                    }

                    if let nameValue = annotation.customData["name"],
                       case let .string(name) = nameValue {
                        
                        let customData: JSONObject = ["name": .string(name), "iconImage": .string(self.isGraySelectedMarker)]
                        self.pointAnnotationManager.annotations[index].customData = customData
                        
                        self.RedirectToDetailsPage(name: name)
                        self.showTitle(annotation: annotation, Title: name)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                        self.zoomToMarker(annotation.point.coordinates, ZoomScale: 11.0, isCheckCondition: true)
                        self.btnBack.isHidden = false
                    }
                }
            }
            
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

//Mark:- Get Firebase Data
extension HomeVC {
    
    func GetFirebaseData() {
        NVActivityIndicatorViewable.show(myView: self.view)
        FirRef.child(self.appDelegate.strCity).observeSingleEvent(of: .value, with: { (snapshot) in
            let userNewArr = NSMutableArray()
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    userNewArr.add(child.value!)
                }
            }
            let modal = DataModel.init(fromDictionary: userNewArr as NSArray)
            self.FirebaseDataArr = modal.FirebaseDataArr
            self.appDelegate.FirebaseAllDataArr = modal.FirebaseDataArr
            
//            let model1 = self.FirebaseDataArr[0]
//            let coordinate = model1.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
//            let Lat = Double(coordinate[0])!
//            let Long = Double(coordinate[1])!
//            let cameraOptions = CameraOptions(center:CLLocationCoordinate2D(latitude: Lat, longitude: Long),zoom: 8, bearing: 0, pitch: 0)
//            let mapInitOptions = MapInitOptions(cameraOptions: cameraOptions)
//            self.mapView = MapView(frame: self.mpView.bounds, mapInitOptions: mapInitOptions)
//            self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            self.mapView.mapboxMap.mapStyle = .standard
//            self.mapView.mapboxMap.loadStyle(.streets)
//            self.mapView.ornaments.options.scaleBar.visibility = .hidden
//            self.mapView.ornaments.options.compass.visibility = .hidden
//            self.mapView.ornaments.options.attributionButton.position = .bottomLeft
//            self.mapView.ornaments.options.attributionButton.margins = CGPoint(x: 90, y: 40)
//            self.mapView.ornaments.options.logo.margins = CGPoint(x: 10, y: 40)
//            self.mpView.addSubview(self.mapView)
//            try! self.mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(
//                maxZoom: 18.0, minZoom: 3.0 ))
//            self.mapView.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NVActivityIndicatorViewable.hide()
                self.LoadMapByDetails()
                NotificationCenter.default.post(name: Notification.Name("ReloadMapDetailsData"), object: nil, userInfo: nil)
            }
            
        })
    }
    
    func LoadMapByDetails() {

        self.mapView.isHidden = false
        self.pointAnnotationManager = self.mapView.annotations.makePointAnnotationManager()
        
        for i in 0...self.FirebaseDataArr.count - 1 {
            let model = self.FirebaseDataArr[i]
            let coordinate = model.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            let Lat = Double(coordinate[0])!
            let Long = Double(coordinate[1])!
            let centerCoordinate = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
            var annotation = PointAnnotation(coordinate: centerCoordinate)
            
            var strIconImage = ""
            if model.isGrayMarker {
                annotation.image = .init(image: UIImage(named: GrayMarker)!, name: GrayMarker)
            }else{
                
                if self.appDelegate.strCity == "Mommydata" {
                    if model.type == "Community Centre" {
                        annotation.image = .init(image: UIImage(named: BlueMarkerNormal)!, name: model.titleName)
                        strIconImage = BlueMarkerNormal
                    }else if model.type == "Family Place" {
                        annotation.image = .init(image: UIImage(named: PinkMarkerNormal)!, name: model.titleName)
                        strIconImage = PinkMarkerNormal
                    }else if model.type == "Neighbourhood House" {
                        annotation.image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: model.titleName)
                        strIconImage = LightBlueMarkerNormal
                    }else if model.type == "Public Library" {
                        annotation.image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: model.titleName)
                        strIconImage = PurpleMarkerNormal
                    }else if model.type == "Restaurant" || model.type == "Retail" || model.type == "Restaurants & Retail" || model.type == "Restaurants and Retail" {
                        annotation.image = .init(image: UIImage(named: WhiteMarkerNormal)!, name: model.titleName)
                        strIconImage = WhiteMarkerNormal
                    }else if model.type == "Health Centre" {
                        annotation.image = .init(image: UIImage(named: HelthMarkerNormal)!, name: model.titleName)
                        strIconImage = HelthMarkerNormal
                    }
                }else{
                    if model.type == "Arts and Nature"  {
                        annotation.image = .init(image: UIImage(named: HelthMarkerNormal)!, name: model.titleName)
                        strIconImage = HelthMarkerNormal
                    }else if model.type == "Community Services" {
                        annotation.image = .init(image: UIImage(named: LightBlueMarkerNormal)!, name: model.titleName)
                        strIconImage = LightBlueMarkerNormal
                    }else if model.type == "Public Library" {
                        annotation.image = .init(image: UIImage(named: BlueMarkerNormal)!, name: model.titleName)
                        strIconImage = BlueMarkerNormal
                    }else if model.type == "Restaurant" || model.type == "Retail" || model.type == "Restaurants & Retail" || model.type == "Restaurants and Retail" {
                        annotation.image = .init(image: UIImage(named: PurpleMarkerNormal)!, name: model.titleName)
                        strIconImage = PurpleMarkerNormal
                    }
                }
                
            }
            
            let customData: JSONObject = ["name": .string(model.titleName), "iconImage": .string(strIconImage)]
            annotation.customData = customData
            annotation.iconImage = model.titleName
            self.annotations.append(annotation)
        }
        pointAnnotationManager.annotations = self.annotations
        pointAnnotationManager.delegate = self
        
        self.mapView.mapboxMap.onEvery(event: .cameraChanged) { [weak self] _ in
            self!.updateTitlePosition()
        }
        
        self.mapView.mapboxMap.onEvery(event: .mapIdle) { [weak self] _ in
            self!.checkMarkersVisibility()
        }

        let model = self.FirebaseDataArr[0]
        let coordinate = model.latLong.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
        let Lat = Double(coordinate[0])!
        let Long = Double(coordinate[1])!
        if self.FirebaseDataArr.count != 0 {
            let centerCoordinate1 = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
            self.FirstCoordinate = centerCoordinate1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.zoomToMarker(centerCoordinate1, ZoomScale: 10.0, isCheckCondition: true)
            }
        }
    }
    
    // Function to zoom into a specific marker when tapped
    func zoomToEaseAnimation(_ coordinate: CLLocationCoordinate2D, ZoomScale:CGFloat) {
        guard !isAnimating else { return }
        self.isAnimating = true
        let cameraOptions = CameraOptions(center: coordinate, zoom: ZoomScale)
        self.mapView.camera.ease(to: cameraOptions, duration: 0.5) { [weak self] _ in
            self!.isAnimating = false
        }
    }
    
    // Function to zoom into a All Visible marker when Filter
    func zoomToMarkerByFilter(_ coordinat: [CLLocationCoordinate2D], ZoomScale:CGFloat, isCheckCondition:Bool) {
        
        guard !isAnimating else { return }
        self.isAnimating = true
        
        let cameraOptions = CameraOptions(zoom: ZoomScale, bearing: 45)
        let camera = try? mapView.mapboxMap.camera(for: coordinat,camera: cameraOptions,coordinatesPadding: .zero,maxZoom: ZoomScale,offset: nil)

        if camera != nil {
            mapView.camera.fly(to: camera!, duration: 0.4) { [weak self] _ in
                self!.isAnimating = false
            }
        }

        self.sheetCoordinator.setPosition(self.sheetCoordinator.maxSheetPosition!, animated: true)

        if isCheckCondition {
            if ZoomScale == 11.0 {
                if self.VwSearchTopConst.constant == 5 {
                    //self.btnCurrentLocationTopConst.constant = 5
                    UIView.animate(withDuration: 0.5, animations: {
                        self.VwSearchTopConst.constant = -200
                        self.view.layoutIfNeeded()
                    }) { (completed) in
                        if completed {
    //                    self.VwSearch.isHidden = true
                        }
                    }
                }
            }else{
                if self.VwSearchTopConst.constant != -200 {
                    //self.btnCurrentLocationTopConst.constant = 65
                    UIView.animate(withDuration: 0.5, animations: {
                        self.VwSearchTopConst.constant = 5
                        self.view.layoutIfNeeded()
                    }) { (completed) in
                        if completed {
    //                    self.VwSearch.isHidden = false
                        }
                    }
                }
            }
        }

    }
    
    // Function to zoom into a specific marker when tapped
    func zoomToMarker(_ coordinate: CLLocationCoordinate2D, ZoomScale:CGFloat, isCheckCondition:Bool) {
        
        guard !isAnimating else { return }
        self.isAnimating = true
        let cameraOptions = CameraOptions(center: coordinate, zoom: ZoomScale)
//        mapView.camera.ease(to: cameraOptions, duration: 0.5)
        mapView.camera.fly(to: cameraOptions, duration: 0.4) { [weak self] _ in
            self!.isAnimating = false
        }

        self.sheetCoordinator.setPosition(self.sheetCoordinator.maxSheetPosition!, animated: true)

        if isCheckCondition {
            if ZoomScale == 11.0 {
                if self.VwSearchTopConst.constant == 5 {
                    //self.btnCurrentLocationTopConst.constant = 5
                    UIView.animate(withDuration: 0.5, animations: {
                        self.VwSearchTopConst.constant = -200
                        self.view.layoutIfNeeded()
                    }) { (completed) in
                        if completed {
    //                    self.VwSearch.isHidden = true
                        }
                    }
                }
            }else{
                if self.VwSearchTopConst.constant != -200 {
                    //self.btnCurrentLocationTopConst.constant = 65
                    UIView.animate(withDuration: 0.5, animations: {
                        self.VwSearchTopConst.constant = 5
                        self.view.layoutIfNeeded()
                    }) { (completed) in
                        if completed {
    //                    self.VwSearch.isHidden = false
                        }
                    }
                }
            }
        }

    }
    
    func SearchVwAnimation(ZoomScale:CGFloat) {
        if ZoomScale == 11.0 {
            //self.btnCurrentLocationTopConst.constant = 5
            UIView.animate(withDuration: 0.5, animations: {
                self.VwSearchTopConst.constant = -200
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                }
            }
        }else{
            //self.btnCurrentLocationTopConst.constant = 65
            UIView.animate(withDuration: 0.5, animations: {
                self.VwSearchTopConst.constant = 5
                self.view.layoutIfNeeded()
            }) { (completed) in
                if completed {
                }
            }
        }
    }
    
}

// MARK: - PointAnnotationManagerDelegate
extension HomeVC: AnnotationInteractionDelegate {
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard let tappedAnnotation = annotations.first else { return }
        
        if self.SelectedIndex != -1 {
            let StrIconName = self.isGraySelectedMarker.replacingOccurrences(of: "Big", with: "")
            self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: UIImage(named: StrIconName)!, name: StrIconName)
            if let nameValue = self.pointAnnotationManager.annotations[self.SelectedIndex].customData["name"],
               case let .string(name) = nameValue {
                let customData: JSONObject = ["name": .string(name), "iconImage": .string(StrIconName)]
                pointAnnotationManager.annotations[self.SelectedIndex].customData = customData
            }
            self.SelectedIndex = -1
        }
        
        for (index, annotation) in pointAnnotationManager.annotations.enumerated() {
            if annotation.id == tappedAnnotation.id {
                print(index)
                self.SelectedIndex = index
                
                if let iconName = annotation.customData["iconImage"],
                   case let .string(name) = iconName {
                    self.isGraySelectedMarker = "Big\(name)"
                    pointAnnotationManager.annotations[index].image = .init(image: UIImage(named: "\(self.isGraySelectedMarker)")!, name: "\(self.isGraySelectedMarker)")
                }
                
                if let nameValue = annotation.customData["name"],
                   case let .string(name) = nameValue {
                    
                    let customData: JSONObject = ["name": .string(name), "iconImage": .string(self.isGraySelectedMarker)]
                    pointAnnotationManager.annotations[index].customData = customData
                    
                    self.showTitle(annotation: annotation, Title: name)
                    self.RedirectToDetailsPage(name: name)
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
                        self.zoomToMarker(annotation.point.coordinates, ZoomScale: 11.0, isCheckCondition: true)
                        self.btnBack.isHidden = false
                    }
                }
            }
        }
    }
    
    func RedirectToDetailsPage(name:String) {
        let MapDetails = self.FirebaseDataArr.filter({ $0.titleName == name })
        if MapDetails.count != 0 {
            let model = MapDetails[0]
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
    
    func showTitle(annotation: PointAnnotation, Title:String) {
        titleLabel?.removeFromSuperview()
        let newTitleLabel = OutlinedLabel() //UILabel()
        newTitleLabel.text = Title.uppercased()
        newTitleLabel.textColor = .black
        newTitleLabel.outlineColor = .white
        newTitleLabel.outlineWidth = 7
        newTitleLabel.numberOfLines = 0
        newTitleLabel.textAlignment = .center
        newTitleLabel.font = UIFont.init(name: "Comfortaa", size: 16) //.systemFont(ofSize: 16.0, weight: .medium) //
        newTitleLabel.frame.size = CGSize(200, 50)
        newTitleLabel.sizeToFit()
        let screenPoint = mapView.mapboxMap.point(for: annotation.point.coordinates)
        newTitleLabel.center = CGPoint(x: screenPoint.x, y: screenPoint.y - 40)
        mapView.addSubview(newTitleLabel)
        titleLabel = newTitleLabel
        currentlySelectedAnnotation = annotation
    }    

    func updateTitlePosition() {
        guard let annotation = currentlySelectedAnnotation, let titleLabel = titleLabel else {
            return
        }
        let screenPoint = mapView.mapboxMap.point(for: annotation.point.coordinates)
        titleLabel.center = CGPoint(x: screenPoint.x, y: screenPoint.y - 40)
    }
    
    func BackCalled() {
        
        guard let parentVC = sheetCoordinator?.parent else { return }
        if parentVC.children.last is AreaCategoryDetailsVC {
            NotificationCenter.default.post(name: Notification.Name("BackCalledArea"), object: nil, userInfo: nil)
        }
        else if parentVC.children.last is SpecificItemDetailsVC {
            NotificationCenter.default.post(name: Notification.Name("BackCalled"), object: nil, userInfo: nil)
        }
        else if parentVC.children.last is TosVC {
            NotificationCenter.default.post(name: Notification.Name("BackCalledTos"), object: nil, userInfo: nil)
        }
        else if parentVC.children.last is AboutUsVC {
            NotificationCenter.default.post(name: Notification.Name("BackCalledAbout"), object: nil, userInfo: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print(parentVC.children.last!)
            if parentVC.children.last is MapDetailVC {
                self.btnBack.isHidden = true
            }
        }
        
        if self.isTappedCurrentLocation {
            let StrIconName = BlueMarkerNormal
            self.pointAnnotationManager.annotations[0].image = .init(image: UIImage(named: StrIconName)!, name: StrIconName)
        }

//        let Normal = UIImage(named: "Marker")
//        let Marker_Gray = UIImage(named: "Marker_Gray")
        if self.SelectedIndex != -1 {
//            if self.isGraySelectedMarker {
//                self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: Marker_Gray!, name: "GrayMarket")
//            }else{
//                self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: Normal!, name: "Marker")
//            }
            let StrIconName = self.isGraySelectedMarker.replacingOccurrences(of: "Big", with: "")
            self.pointAnnotationManager.annotations[self.SelectedIndex].image = .init(image: UIImage(named: StrIconName)!, name: StrIconName)
            if let nameValue = self.pointAnnotationManager.annotations[self.SelectedIndex].customData["name"],
               case let .string(name) = nameValue {
                let customData: JSONObject = ["name": .string(name), "iconImage": .string(StrIconName)]
                pointAnnotationManager.annotations[self.SelectedIndex].customData = customData
            }
            self.SelectedIndex = -1
        }
        self.titleLabel?.removeFromSuperview()
        DispatchQueue.main.asyncAfter(deadline: .now() + self.animationDuration) {
            if self.appDelegate.isSelectedCategory == "" {
                self.zoomToMarker(self.FirstCoordinate, ZoomScale: 10.0, isCheckCondition: true)
            }else{
                self.zoomToMarker(self.FirstCoordinate, ZoomScale: 9.0, isCheckCondition: true)
            }
        }
    }
    
    // Function to check if all markers are within the visible bounds of the map
    func checkMarkersVisibility() {
        let CustomeFrame = CGRect(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width + 10, self.mapView.frame.size.height)
        let visibleBounds = self.mapView.mapboxMap.coordinateBounds(for: CustomeFrame)
        let areAllMarkersVisible = self.annotations.allSatisfy { marker in
            !visibleBounds.contains(forPoint: marker.point.coordinates, wrappedCoordinates: true)
        }
        self.btnGoBackNYC.isHidden = !areAllMarkersVisible
    }
}
