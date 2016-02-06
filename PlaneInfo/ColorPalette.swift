//
//  Colors.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 2/5/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import UIKit

enum ColorPalette {
    case MainColor
    case SecondaryColor
    case DarkColor
    case LightColor
    
    var color: UIColor {
        switch self {
        case .MainColor:
            return UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1)
        case .SecondaryColor:
            return UIColor(red: 63.0/255.0, green: 52.0/255.0, blue: 219.0/255.0, alpha: 1)
        case .DarkColor:
            return UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
        case .LightColor:
            return UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 215.0/255.0, alpha: 1)
        }
    }
}
