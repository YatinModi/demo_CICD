//
//  LetsButton.swift
//  LetsButton
//
//  Created by Ketan Raval on 28/09/15.
//  Copyright (c) 2015 Ketan Raval. All rights reserved.
//

import UIKit

@IBDesignable
class LetsButton : UIButton {
    var topBorder: UIView?
    var bottomBorder: UIView?
    var leftBorder: UIView?
    var rightBorder: UIView?
    @IBInspectable var highlightedBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setBackgroundImage(getImageWithColor(color: highlightedBackgroundColor, size: CGSize(1, 1)), for: .highlighted)
        }
    }
    @IBInspectable var normalBackgroundColor: UIColor = UIColor.clear {
        didSet {
            setBackgroundImage(getImageWithColor(color: normalBackgroundColor, size: CGSize(1, 1)), for: .normal)
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    @IBInspectable var isCircle: Bool = false {
        didSet {
            layer.cornerRadius = frame.width/2
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
    override func draw(_ rect: CGRect) {
        var edge = self.titleEdgeInsets
        edge.bottom = 0.0
        edge.top = 0.0
        self.titleEdgeInsets = edge
        if bottomBorder != nil{
            bottomBorder?.frame = CGRect(0, self.frame.size.height - bottomBorderHeight, self.frame.size.width, bottomBorderHeight)
        }
    }
    
}
func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(0, 0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
