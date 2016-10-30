//
//  User.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/26/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var screenName: String?
    var profileUrl: URL?
    var tagLine: String?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
        
        tagLine = dictionary["description"] as? String
        
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                
                let userData = defaults.object(forKey: "currentUserData") as? Data
                let logKey   = defaults.object(forKey: "logKey") as? Bool ?? false
                
                if let userData = userData {
                    if logKey == true {
                        let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                        
                        _currentUser = User(dictionary: dictionary)
                    }
                }
            }
            
            return _currentUser
        }
        
        set(user) {
            _currentUser = user 
            
            let defaults = UserDefaults.standard
            
            if _currentUser != nil {
                let data = try! JSONSerialization.data(withJSONObject: user!.dictionary!, options: [])
                
                defaults.set(data, forKey: "currentUserData")
                
            } else {
                defaults.set(nil, forKey: "currentUserData")
            }
            
            defaults.synchronize()
        }
    }
    
}
