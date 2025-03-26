//
//  CitySelectionVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 13/11/24.
//

import UIKit

class CitySelectionVC: UIViewController {
    
    @IBOutlet weak var VwGradiunt: UIView!
    var isDismiss = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.VwGradiunt.applyGradient(colors: [#colorLiteral(red: 0.8786390424, green: 0.9253688455, blue: 0.9721665978, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.9019607843, blue: 0.9019607843, alpha: 1)])
    }

}

//Mark:- UIButton Action
extension CitySelectionVC {
    @IBAction func btnVitageCity(_ sender: UIButton) {
        if self.isDismiss {
            self.appDelegate.strCity = "Mommydata"
            UserDefaults.standard.setValue(self.appDelegate.strCity, forKey: myStrings.KMapCity)
            self.appDelegate.navigationControll(identifier: "HomeVC", storyboardName: "Main", msg: "")
        }else{
            let vc = MainStory.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.appDelegate.strCity = "Mommydata"
            UserDefaults.standard.setValue(self.appDelegate.strCity, forKey: myStrings.KMapCity)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func btnSantaFeCity(_ sender: UIButton) {
        if self.isDismiss {
            self.appDelegate.strCity = "SantaFeMommyMap"
            UserDefaults.standard.setValue(self.appDelegate.strCity, forKey: myStrings.KMapCity)
            self.appDelegate.navigationControll(identifier: "HomeVC", storyboardName: "Main", msg: "")
        }else{
            let vc = MainStory.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.appDelegate.strCity = "SantaFeMommyMap"
            UserDefaults.standard.setValue(self.appDelegate.strCity, forKey: myStrings.KMapCity)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
