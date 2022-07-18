//
//  UIImage.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 18/07/22.
//

import Foundation
import UIKit

extension UIImage {
    
    static var openEyeImage: UIImage {
        return image(name: "eye_light")
    }
    
    static var closedEyeImage: UIImage {
        return image(name: "")
    }
    
    // MARK: - Methods
    static fileprivate func image(name: String) -> UIImage {
        guard let color = UIImage(named: name) else {
            fatalError("Couldn't load \(name) image.")
        }
        return color
    }
    
}
