//
//  MyDataSource.swift
//  UBottomSheet_Example
//
//  Created by ugur on 2.05.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import UBottomSheet

//class MyDataSource: UBottomSheetCoordinatorDataSource {
//    func sheetPositions(_ availableHeight: CGFloat) -> [CGFloat] {
//        return [0.2, 0.4, 0.6, 0.8].map{$0*availableHeight}
//    }
//    
//    func initialPosition(_ availableHeight: CGFloat) -> CGFloat {
//        return availableHeight
//    }
//}

class MyDataSource: UBottomSheetCoordinatorDataSource {
    func sheetPositions(_ availableHeight: CGFloat) -> [CGFloat] {
        return [0.1,0.2,0.3,0.4,0.5,0.6,0.7, 0.8,0.9].map{$0*availableHeight}
    }
    
    func initialPosition(_ availableHeight: CGFloat) -> CGFloat {
        return availableHeight*0.4
    }
}

