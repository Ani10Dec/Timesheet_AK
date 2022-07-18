//
//  LocalStorage.swift
//  Timesheet_AK
//
//  Created by Aniket Kumar on 18/07/22.
//

import Foundation


class LocalStorage {
    
   private let defaults = UserDefaults.standard
    
    func setUIDValue(value: String) {
        defaults.setValue(value, forKey: AppConstants.USER_UID)
    }
}
