

import UIKit
import NVActivityIndicatorView

class NVActivityIndicatorViewable: NSObject {
    
    static let sharedInstance = NVActivityIndicatorViewable()
    
    let myIndicatorView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.height/2 , y: UIScreen.main.bounds.size.height/2, width: 50, height: 50), type: NVActivityIndicatorType.circleStrokeSpin, color: myColors.AppLoaderColor, padding: 5.0)
    let NewView=UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
    let myIndicatorViewWhite = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.size.height/2 , y: UIScreen.main.bounds.size.height/2, width: 50, height: 50), type: NVActivityIndicatorType.circleStrokeSpin, color: UIColor.white, padding: 5.0)
    let NewViewWhite=UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
    
    class func show(myView : UIView) -> Void {
        DispatchQueue.main.async {
            UIApplication.shared.beginIgnoringInteractionEvents()
            NVActivityIndicatorViewable.sharedInstance.myIndicatorView.center = myView.center
            NVActivityIndicatorViewable.sharedInstance.NewView.backgroundColor = UIColor.clear
            NVActivityIndicatorViewable.sharedInstance.NewView.isUserInteractionEnabled = false
            myView.addSubview(NVActivityIndicatorViewable.sharedInstance.NewView)
            myView.addSubview(NVActivityIndicatorViewable.sharedInstance.myIndicatorView)
            NVActivityIndicatorViewable.sharedInstance.myIndicatorView.startAnimating()
        }
    }
    
    class func hide() -> Void {
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
            NVActivityIndicatorViewable.sharedInstance.NewView.removeFromSuperview()
            NVActivityIndicatorViewable.sharedInstance.myIndicatorView.stopAnimating()
        }
    }
   
    
    
}
