//
//  UserData.swift
//  UMGameController
//
//  Created by fOrest on 01/10/2016.
//  Copyright © 2016 fOrest. All rights reserved.
//

import Foundation

enum UserDataKeys: String {
    
    case connMode       = "connectionMode"
    case gameDict       = "gameSceneDictionary"
}

class UserData {
    
    private static let defaults = UserDefaults.standard
    
    static func getValue(_ forKey: String)-> Any? {
        
        return defaults.object(forKey: forKey)
    }
    
    static func setValue(value object: Any?, forKey key: String) {
        
        return defaults.set(object, forKey: key)
    }
}
