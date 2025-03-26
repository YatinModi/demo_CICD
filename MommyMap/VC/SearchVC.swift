//
//  SearchVC.swift
//  MommyMap
//
//  Created by getyoteam solution llp on 28/09/24.
//

import UIKit

class SearchVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var VwSearch : UIView!
    @IBOutlet weak var txtSearch : UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblNoResult: UILabel!

    var FirebaseDataArr = [firebaseDataModel]()
    var SimpleClosure: ((_ strName: String) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtSearch.delegate = self
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.tableFooterView = UIView()
        self.txtSearch.becomeFirstResponder()
        
        let xPosition = VwSearch.frame.origin.x
        let yPosition = VwSearch.frame.origin.y + 6
        let width = VwSearch.frame.size.width
        let height = VwSearch.frame.size.height
        UIView.animate(withDuration: 0.2, animations: {
            self.VwSearch.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        })
    }

}

//Mark:- UItextfiled Methods
extension SearchVC {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtSearch {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                self.FirebaseDataArr = self.appDelegate.FirebaseAllDataArr.filter { $0.titleName.lowercased().contains(updatedText.lowercased()) }
                self.tblView.reloadData()
                self.tblView.isHidden = self.FirebaseDataArr.count == 0 ? true : false
                self.lblNoResult.isHidden = self.FirebaseDataArr.count == 0 ? false : true
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtSearch && self.txtSearch.text == "" {
            self.FirebaseDataArr.removeAll()
            self.tblView.reloadData()
            self.tblView.isHidden = true
            self.lblNoResult.isHidden = true
        }
    }

}

//Mark:- UIButton Action
extension SearchVC {
    @IBAction func btnBack(_ sender: UIButton) {
        self.GoBackWithAnimation()
    }
}

//Mark:- UITableView Methods
extension SearchVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.FirebaseDataArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let acell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchItemCell
        acell.selectionStyle = .gray
        let model = self.FirebaseDataArr[indexPath.row]
        acell.lblName.text = model.titleName
        return acell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tblView.deselectRow(at: indexPath, animated: true)
        let model = self.FirebaseDataArr[indexPath.row]
        self.SimpleClosure!(model.titleName)
        self.GoBackWithAnimation()
    }
}

class SearchItemCell: UITableViewCell {
    @IBOutlet weak var vwBack: UIView!
    @IBOutlet weak var imgVw: UIImageView!
    @IBOutlet weak var lblName: UILabel!
}
