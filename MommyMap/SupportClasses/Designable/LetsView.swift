//
//  LetsView.swift
//  LetsView
//
//  Created by Ketan Raval on 07/10/15.
//  Copyright © 2015 Ketan Raval. All rights reserved.
//

import UIKit
@IBDesignable
class LetsView : UIView {
    var topBorder: UIView?
    var bottomBorder: UIView?
    var leftBorder: UIView?
    var rightBorder: UIView?
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var ShadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = ShadowColor.cgColor
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var ShadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = ShadowRadius
            layer.masksToBounds = true
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            layer.masksToBounds = true
        }
    }
    
   private var _round = false
    @IBInspectable var round: Bool {
        set {
            _round = newValue
            makeRound()
        }
        get {
            return self._round
        }
    }
    override internal var frame: CGRect {
        set {
            super.frame = newValue
            makeRound()
        }
        get {
            return super.frame
        }
        
    }
    
    private func makeRound() {
        if self.round == true {
            self.clipsToBounds = true
            self.layer.cornerRadius = (self.frame.width + self.frame.height) / 4
        } else {
            self.layer.cornerRadius = 0
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    @IBInspectable var topBorderColor : UIColor = UIColor.clear
    @IBInspectable var topBorderHeight : CGFloat = 0 {
        didSet{
            if topBorder == nil{
                topBorder = UIView()
                topBorder?.backgroundColor=topBorderColor;
                topBorder?.frame = CGRect(0, 0, self.frame.size.width, topBorderHeight)
                addSubview(topBorder!)
            }
        }
    }
    @IBInspectable var bottomBorderColor : UIColor = UIColor.clear
    @IBInspectable var bottomBorderHeight : CGFloat = 0 {
        didSet{
            if bottomBorder == nil{
                bottomBorder = UIView()
                bottomBorder?.backgroundColor=bottomBorderColor;
                bottomBorder?.frame = CGRect(0, self.frame.size.height - bottomBorderHeight, self.frame.size.width, bottomBorderHeight)
                addSubview(bottomBorder!)
            }
        }
    }
    @IBInspectable var leftBorderColor : UIColor = UIColor.clear
    @IBInspectable var leftBorderHeight : CGFloat = 0 {
        didSet{
            if leftBorder == nil{
                leftBorder = UIView()
                leftBorder?.backgroundColor=leftBorderColor;
                leftBorder?.frame = CGRect(0, 0, leftBorderHeight, self.frame.size.height)
                addSubview(leftBorder!)
            }
        }
    }
    @IBInspectable var rightBorderColor : UIColor = UIColor.clear
    @IBInspectable var rightBorderHeight : CGFloat = 0 {
        didSet{
            if rightBorder == nil{
                rightBorder = UIView()
                rightBorder?.backgroundColor=topBorderColor;
                rightBorder?.frame = CGRect(self.frame.size.width - rightBorderHeight, 0, rightBorderHeight, self.frame.size.height)
                addSubview(rightBorder!)
            }
        }
    }
    
    override func layoutSubviews() {
        if topBorder != nil{
            topBorder?.frame = CGRect(0, 0, self.frame.width, topBorderHeight)
        }
        if bottomBorder != nil{
            bottomBorder?.frame = CGRect(0, self.frame.height - bottomBorderHeight, self.frame.size.width, bottomBorderHeight)
        }
    }
    override func draw(_ rect: CGRect) {
        if topBorder != nil{
            topBorder?.frame = CGRect(0, 0, rect.width, topBorderHeight)
        }
        if bottomBorder != nil{
            bottomBorder?.frame = CGRect(0, rect.height - bottomBorderHeight, rect.size.width, bottomBorderHeight)
        }
    }
    
}

