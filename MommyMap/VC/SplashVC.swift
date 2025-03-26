//
//  SplashVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 15/11/24.
//

import UIKit

class SplashVC: UIViewController {

    @IBOutlet weak var VwGradiunt: UIView!
    @IBOutlet weak var VwZoomAnimation: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.VwGradiunt.applyGradient(colors: [#colorLiteral(red: 0.8786390424, green: 0.9253688455, blue: 0.9721665978, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.9019607843, blue: 0.9019607843, alpha: 1)])
        
        self.VwZoomAnimation.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 4.0,
                       delay: 0.1,
                       options: .curveEaseInOut,
                       animations: {
            self.VwZoomAnimation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: { _ in
            self.setRootScreen()
        })

    }
    
    func setRootScreen() {
//        if UserDefaults.standard.value(forKey: myStrings.KMapCity) != nil {
//            let strName = UserDefaults.standard.value(forKey: myStrings.KMapCity) as? String ?? ""
//            self.appDelegate.strCity = strName
//            self.appDelegate.navigationControll(identifier: "HomeVC", storyboardName: "Main", msg: "")
//        }else{
//            self.appDelegate.navigationControll(identifier: "CitySelectionVC", storyboardName: "Main", msg: "")
//        }
        
        let transition:CATransition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CitySelectionVC") as! CitySelectionVC
        self.navigationController?.pushViewController(vc, animated: false)

    }
    
}

extension UIView {
    func applyGradient(colors: [UIColor], locations: [NSNumber]? = nil) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // Top-left
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)   // Bottom-right
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
