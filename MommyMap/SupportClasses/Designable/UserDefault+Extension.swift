//
//  UserDefault+Extension.swift
//  Meditation
//
//  Created by smartlap on 04/01/21.
//  Copyright © 2021 Raavi Katariya. All rights reserved.
//

import UIKit

// `UserDefaults` Extension for Siren.
extension UserDefaults {
    /// Siren-specific `UserDefaults` Keys
    private enum keys: String {
        /// Key that notifies Siren to perform a version check and present
        /// the Siren alert the next time the user launches the app.
        case InstructionFinish
    }

    
    /// Sets and Gets a `UserDefault` around the last time the user was presented a version update alert.
    
    static var isInstructionFinished:Bool?{
        get{
            return standard.bool(forKey: keys.InstructionFinish.rawValue) as? Bool
        }
        set{
            standard.set(newValue, forKey: keys.InstructionFinish.rawValue)
        }
    }
}
