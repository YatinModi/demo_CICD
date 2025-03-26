//
//  Constant.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 26/09/24.
//

import Foundation
import FirebaseDatabase

let MainStory = UIStoryboard.init(name: "Main", bundle: nil)
let App_Delegate = UIApplication.shared.delegate as? AppDelegate
let FirRef = Database.database().reference()
let strNetworkMSG = "No Internet"

let PinkMarkerNormal = "FamilyPlace" //Family Place
let BlueMarkerNormal = "CommunityCentre" //Community Centre
let LightBlueMarkerNormal = "NaighborhoodHouse" //Neighbourhood House
let PurpleMarkerNormal = "Library" //Public Library
let HelthMarkerNormal = "HealthCentre" //Health Centre
let WhiteMarkerNormal = "Restrarant" //Restaurant/Reatil
//let WhiteMarkerNormal = "MarkerWhite"

let GrayMarker = "Marker_Gray"

let PinkMarkerBig = "BigFamilyPlace"
let BlueMarkerBig = "BigCommunityCentre"
let LightBlueMarkerBig = "BigNaighborhoodHouse"
let PurpleMarkerBig = "BigLibrary"
let HelthMarkerBig = "BigHealthCentre"
let WhiteMarkerBig = "BigRestrarant"
//let WhiteMarkerBig = "BigMarkerWhite"

struct myColors {
    
    static let AppStatusColor: UIColor = UIColor(red: 243/255.0, green: 58.0/255.0, blue: 89.0/255.0, alpha: 1.0)
    
    static let AppLoaderColor: UIColor = .black //UIColor(red: 255/255.0, green: 110.0/255.0, blue: 161.0/255.0, alpha: 1.0)

    static let AppBlueColor: UIColor = UIColor(red: 174.0/255.0, green: 182.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    
    static let AppPlaceholderColor: UIColor = #colorLiteral(red: 0.5803921569, green: 0.5882352941, blue: 0.6352941176, alpha: 1)
}

struct myStrings
{
    static let KUSERNICKNAME: String = "KUserNickName"
    static let KLOGINTYPE: String = "KloginType"
    static let SystemDetails: String = "\(UIDevice.current.name),OS-\(UIDevice.current.systemVersion)"
    static let KMapCity: String = "kIsMapCity"
}

extension UIViewController {
    
    func setStatusColor(color:UIColor) {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height+5
            
            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
            statusbarView.backgroundColor = color
            view.addSubview(statusbarView)
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
        }
    }
        
    var appDelegate:SceneDelegate {
        return UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
    }
    
    var APPDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var UD:UserDefaults {
        return  UserDefaults.standard
    }
    
    struct Miscellaneous {
        static let APPDELEGATE  = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
    }
    
    func makeToast(toastMessage : String) -> Void
    {
        var style = ToastStyle()
        style.backgroundColor = UIColor.black
        style.titleColor = myColors.AppLoaderColor
        style.titleAlignment = NSTextAlignment.center
        style.messageAlignment = NSTextAlignment.center
        Miscellaneous.APPDELEGATE.window!.makeToast(toastMessage, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
    }
    
    func showMyAlert(myMessage : String) -> Void {
        let alertController = UIAlertController(title: myMessage, message: "", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func GoNext(identifire: String, StoryName:String) {
        let storyboard = UIStoryboard(name: StoryName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifire) as UIViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func GoBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func GoNextWithAnimation(toScreen: String, StoryName:String) {
//        let transition:CATransition = CATransition()
//        transition.duration = 0
//        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: StoryName, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: toScreen) as UIViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    func GoBackWithAnimation() {
//        let transition:CATransition = CATransition()
//        transition.duration = 0
//        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }

        
    func showNoInternetConn() {
        let label = UILabel()
        
        label.frame = CGRect(x: UIScreen.main.bounds.size.width/2 - 250, y: 50, width: 350, height: 150)
        label.backgroundColor = .black //myColors.AppErrorColor
        label.text = "No Internet Connection."
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        self.view.addSubview(label)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            //label.removeFromSuperview()
            UIView.animate(withDuration: 1, animations: {
                
                label.backgroundColor = .black.withAlphaComponent(0)
                label.removeFromSuperview()
                
            })
        }
    }
    
}

extension UIView {
    
    func RemoveSadow(view:UIView)  {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 0
    }
    func SetSadowWithHeader(view:UIView)  {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2
    }

    func SetSadow(view:UIView)  {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2
    }

    func SetSadowAllSide(view:UIView)  {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 0
    }
    
    //Apply Shadow
    func shadowApply()
    {
//        self.layer.shadowColor = UIColor(red:26, green:187, blue:156, alpha:0.2).cgColor
//        self.layer.shadowOpacity = 0.3
//        self.layer.shadowOffset = CGSize(width: 0, height: 3)
////        self.layer.shadowRadius = 6
//        self.layer.masksToBounds = false
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 15.0
    }
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var setShadowColor:UIColor? {
        set {
            layer.shadowColor = (newValue?.cgColor)!
            layer.shadowOffset = CGSize.zero
            layer.shadowRadius = 3
            layer.shadowOpacity = 0.05
            layer.cornerRadius = 10
            layer.masksToBounds = false
        }
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.layoutIfNeeded()
    }
}

//@IBDesignable
class SSSegmentedControl: UIView {
    
    //MARK: - Properties
    var stackView: UIStackView = UIStackView()
    var buttonsCollection: [UIButton] = []
    var currentIndexView: UIView = UIView(frame: .zero)
    
    var buttonPadding: CGFloat = 2
    var stackViewSpacing: CGFloat = 0
    
    //MARK: - Callback
    var didTapSegment: ((Int) -> ())?
    
    //MARK: - Inspectable Properties
    @IBInspectable var currentIndex: Int = 0 {
        didSet {
            setCurrentIndex()
        }
    }
    
    @IBInspectable var currentIndexTitleColor: UIColor = .white {
        didSet {
            updateTextColors()
        }
    }
    
    @IBInspectable var currentIndexBackgroundColor: UIColor = .systemTeal {
        didSet {
            setCurrentViewBackgroundColor()
        }
    }
    
    @IBInspectable var otherIndexTitleColor: UIColor = .gray {
        didSet {
            updateTextColors()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 22 {
        didSet {
            setCornerRadius()
        }
    }
    
    @IBInspectable var buttonCornerRadius: CGFloat = 18 {
        didSet {
            setButtonCornerRadius()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .systemTeal {
        didSet {
            setBorderColor()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            setBorderWidth()
        }
    }
    
    @IBInspectable var numberOfSegments: Int = 2 {
        didSet {
            addSegments()
        }
    }
    
    @IBInspectable var segmentsTitle: String = "Segment 1,Segment 2" {
        didSet {
            updateSegmentTitles()
        }
    }
    
    //MARK: - Life cycle
    override init(frame: CGRect) { //From code
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) { //From IB
        super.init(coder: coder)
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setCurrentIndex()
    }
    
    //MARK: - Functions
    private func commonInit() {
        backgroundColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 1) //.clear
        
        setupStackView()
        addSegments()
        setCurrentIndexView()
        setCurrentIndex(animated: false)
        
        setCornerRadius()
        setButtonCornerRadius()
        setBorderColor()
        setBorderWidth()
    }
    
    private func setCurrentIndexView() {
        setCurrentViewBackgroundColor()
        
        addSubview(currentIndexView)
        sendSubviewToBack(currentIndexView)
    }
    
    private func setCurrentIndex(animated: Bool = true) {
        stackView.subviews.enumerated().forEach { (index, view) in
            let button: UIButton? = view as? UIButton
            
            if index == currentIndex {
                let buttonWidth = (frame.width - (buttonPadding * 2)) / CGFloat(numberOfSegments)
                
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        self.currentIndexView.frame =
                        CGRect(x: self.buttonPadding + (buttonWidth * CGFloat(index)),
                               y: self.buttonPadding,
                               width: buttonWidth,
                               height: self.frame.height - (self.buttonPadding * 2))
                    }
                } else {
                    self.currentIndexView.frame =
                    CGRect(x: self.buttonPadding + (buttonWidth * CGFloat(index)),
                           y: self.buttonPadding,
                           width: buttonWidth,
                           height: self.frame.height - (self.buttonPadding * 2))
                }
                
                button?.setTitleColor(currentIndexTitleColor, for: .normal)
            } else {
                button?.setTitleColor(otherIndexTitleColor, for: .normal)
            }
        }
    }
    
    private func updateTextColors() {
        stackView.subviews.enumerated().forEach { (index, view) in
            let button: UIButton? = view as? UIButton
            
            if index == currentIndex {
                button?.setTitleColor(currentIndexTitleColor, for: .normal)
            } else {
                button?.setTitleColor(otherIndexTitleColor, for: .normal)
            }
        }
    }
    
    private func setCurrentViewBackgroundColor() {
        currentIndexView.backgroundColor = currentIndexBackgroundColor
    }
    
    private func setupStackView() {
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = stackViewSpacing
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: buttonPadding),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -buttonPadding),
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: buttonPadding),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -buttonPadding)
            ]
        )
    }
    
    private func addSegments() {
        //Remove buttons
        buttonsCollection.removeAll()
        stackView.subviews.forEach { view in
            (view as? UIButton)?.removeFromSuperview()
        }
        
        let titles = segmentsTitle.split(separator: ",")
        
        for index in 0 ..< numberOfSegments {
            let button = UIButton()
            button.tag = index
            
            if let index = titles.indices.contains(index) ? index : nil {
                button.setTitle(String(titles[index]), for: .normal)
            } else {
                button.setTitle("<Segment>", for: .normal)
            }
            
            button.titleLabel?.font = UIFont.init(name: "Comfortaa-Bold", size: 16) //.systemFont(ofSize: 18.0, weight: .bold)
            button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            buttonsCollection.append(button)
        }
    }
    
    private func updateSegmentTitles() {
        let titles = segmentsTitle.split(separator: ",")
        
        stackView.subviews.enumerated().forEach { (index, view) in
            if let index = titles.indices.contains(index) ? index : nil {
                (view as? UIButton)?.setTitle(String(titles[index]), for: .normal)
            } else {
                (view as? UIButton)?.setTitle("<Segment>", for: .normal)
            }
        }
    }
    
    private func setCornerRadius() {
        layer.cornerRadius = cornerRadius
    }
    
    private func setButtonCornerRadius() {
        stackView.subviews.forEach { view in
            (view as? UIButton)?.layer.cornerRadius = cornerRadius
        }
        
        currentIndexView.layer.cornerRadius = cornerRadius
    }
    
    private func setBorderColor() {
        layer.borderColor = borderColor.cgColor
    }
    
    private func setBorderWidth() {
        layer.borderWidth = borderWidth
    }
    
    //MARK: - IBActions
    @objc func segmentTapped(_ sender: UIButton) {
        didTapSegment?(sender.tag)
        currentIndex = sender.tag
    }

}
