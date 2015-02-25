//
//  Color.swift
//  FCModelTest
//
//  Created by Ahmad Alhashemi on 2015-02-23.
//  Copyright (c) 2015 Marco Arment. All rights reserved.
//

import Foundation

func UIColorFromHex(rgbValue : UInt32) -> UIColor {
    let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
    let g = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
    let b  = CGFloat(rgbValue & 0xFF) / 255.0
    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
}

@objc(Color)
class Color : FCModel {
    var name = "" // database primary key (doesn't have to be an integer)
    var hex = "" // database column
    
    // not a database column
    var colorValue : UIColor {
        get {
            var hexColor : UInt32 = 0
            NSScanner(string: self.hex).scanHexInt(&hexColor)
            return UIColorFromHex(hexColor)
        }
    }
}
