//
//  UIColor+Extension.swift
//  virtual-tourist
//
//  Created by Arman on 24/06/2020.
//  Copyright © 2020 Arman. All rights reserved.
//

import UIKit
extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
    
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
