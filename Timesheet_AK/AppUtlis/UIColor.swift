//
//  UIColor.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 17/07/22.
//

import Foundation
import UIKit


extension UIColor {
    
    static var blueColor: UIColor {
        return color(name: "blue")
    }
    
    static var yellowColor: UIColor {
        return color(name: "dark_yellow")
    }
    
    static var redColor: UIColor {
        return color(name: "red")
    }
    
    static var greenColor: UIColor {
        return color(name: "green")
    }
    
    
    // MARK: - Methods
    static fileprivate func color(name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            fatalError("Couldn't load \(name) color.")
        }
        return color
    }
}
