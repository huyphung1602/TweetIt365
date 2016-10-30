//
//  Tweet.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/26/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var timeStamp: NSDate?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var replyCount: Int = 0
    var userUrl: URL?
    var userName: String?
    var screenName: String?
    var idStr: String?
    var favorited: Bool?
    var retweeted: Bool?
    
    init(dictionary: NSDictionary) {
        text = dictionary["text"] as? String
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        let timeStampString = dictionary["created_at"] as? String
        if let timeStampString = timeStampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timeStamp = formatter.date(from: timeStampString) as NSDate?
        }
        
        let userUrlString = dictionary.value(forKeyPath: "user.profile_image_url_https") as? String
        if let userUrlString = userUrlString {
            userUrl = URL(string: userUrlString)
        }
        
        userName = dictionary.value(forKeyPath: "user.name") as? String
        screenName = dictionary.value(forKeyPath: "user.screen_name") as? String
        
        idStr = dictionary["id_str"] as? String
        
        favorited = dictionary["favorited"] as? Bool
        retweeted = dictionary["retweeted"] as? Bool
        
    }
    
    class func tweetsWithArray (dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            
            tweets.append(tweet)
        }
        
        return tweets
    }
    
}
