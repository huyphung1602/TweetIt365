//
//  TwitterClient.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/28/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: URL(string: "https://api.twitter.com"), consumerKey: "dJ2qLsJQjtZM57KaZBbtkgysE", consumerSecret: "Qnk5KpirVxLMBQZGC4ZRT2v0hzETtpCz0oihu3Ci93aupN7Ifu")

    var loginSuccess: (() -> ())?
    var loginFailure: ((Error?) -> ())?
    
    var postTweetSuccess: ((NSDictionary) -> ())?
    var postTweetFailure: ((Error?) -> ())?
    
    var createFavoriteSuccess: ((NSDictionary) -> ())?
    var createFavoriteFailure: ((Error?) -> ())?
    
    var destroyFavoriteSuccess: ((NSDictionary) -> ())?
    var destroyFavoriteFailure: ((Error?) -> ())?
    
    var doRetweetSuccess: ((NSDictionary) -> ())?
    var doRetweetFailure: ((Error?) -> ())?
    
    var doUnRetweetSuccess: ((NSDictionary) -> ())?
    var doUnRetweetFailure: ((Error?) -> ())?
    
    var replyTweetSuccess: ((NSDictionary) -> ())?
    var replyTweetFailure: ((Error?) -> ())?
    
    // Function used to login
    func login(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        
        loginSuccess = success
        loginFailure = failure
        
        TwitterClient.sharedInstance?.deauthorize()
        
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "oauth/request_token", method: "POST", callbackURL: URL(string: "tweetit365://oauth"), scope: nil, success: { (response: BDBOAuth1Credential?) in
            
            let responseToken = String(response!.token)
            print("[INFO] I got the request token = \(responseToken!)")
            
            let authUrl = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(responseToken!)")
            UIApplication.shared.openURL(authUrl!)
            
            // Save key to track login or logout
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "logKey")
            print("[INFO] Set logKey = true")
            defaults.synchronize()
            
        }) { (error: Error?) in
            print("[ERROR] \(error?.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    // Function used to log out
    func logOut() {
        User.currentUser = nil
        
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UserDidLogOut"), object: nil)
    }
    
    // Function used to get info on home_timeline
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error?) -> () ) {
        
        get("/1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            
            let dictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
        
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask? , error: Error?) in
            failure(error)
        })
        
    }
    
    // Function used to get current user info
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error?) -> ()) {
        
        get("/1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let userDictionary =  response as! NSDictionary
            
            let user = User(dictionary: userDictionary)
            
            success(user)
            
        }, failure: { (task: URLSessionDataTask? , error: Error?) in
            failure(error)
        })
    
    }
    
    // Function used to handle user URL
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (response: BDBOAuth1Credential?) in
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error?) in
                self.loginFailure?(error)
            })
            
        }){ (error: Error?) in
            print("[ERROR] \(error?.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    
    // Function used to post new tweet
    func postTweet(status: String, success: @escaping (NSDictionary) -> (), failure: @escaping (Error?) -> ()) {
        
        postTweetSuccess = success
        postTweetFailure = failure
        
        var parameters = Dictionary<String, Any>()
        
        parameters["status"] = status
        
        post("/1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let dictionary = response as! NSDictionary
            
            self.postTweetSuccess?(dictionary)
            
        }, failure: { (task: URLSessionDataTask? , error: Error?) in
            self.postTweetFailure?(error)
        })
    }
    
    // Function used to create favorite to a tweet
    func createFavorite(id: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error?) -> ()) {
        
        createFavoriteSuccess = success
        createFavoriteFailure = failure
        
        var parameters = Dictionary<String, Any>()
        
        parameters["id"] = id
        
        post("/1.1/favorites/create.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let dictionary = response as! NSDictionary
            
            self.createFavoriteSuccess?(dictionary)
            
            }, failure: { (task: URLSessionDataTask? , error: Error?) in
                self.createFavoriteFailure?(error)
        })
    }
    
    // Function used to destroy favorite to a tweet
    func destroyFavorite(id: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error?) -> ()) {
        
        destroyFavoriteSuccess = success
        destroyFavoriteFailure = failure
        
        var parameters = Dictionary<String, Any>()
        
        parameters["id"] = id
        
        post("1.1/favorites/destroy.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let dictionary = response as! NSDictionary
            
            self.destroyFavoriteSuccess?(dictionary)
            
            }, failure: { (task: URLSessionDataTask? , error: Error?) in
                self.destroyFavoriteFailure?(error)
        })
    }
    
    
    // Function used to reweet
    func doRetweet(id: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error?) -> ()) {
        
        doRetweetSuccess = success
        doRetweetFailure = failure
        
        var parameters = Dictionary<String, Any>()
        
        parameters["id"] = id
        
        post("1.1/statuses/retweet/\(id).json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let dictionary = response as! NSDictionary
            
            self.doRetweetSuccess?(dictionary)
            
            }, failure: { (task: URLSessionDataTask? , error: Error?) in
                self.doRetweetFailure?(error)
        })
    }
    
    // Function used to unreweet
    func doUnRetweet(id: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error?) -> ()) {
        
        doUnRetweetSuccess = success
        doUnRetweetFailure = failure
        
        var parameters = Dictionary<String, Any>()
        
        parameters["id"] = id
        
        post("/1.1/statuses/unretweet/\(id).json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let dictionary = response as! NSDictionary
            
            self.doUnRetweetSuccess?(dictionary)
            
            }, failure: { (task: URLSessionDataTask? , error: Error?) in
                self.doUnRetweetFailure?(error)
        })
    }
    
    // Function used to reply tweet
    func replyTweet(status: String, id: Int, success: @escaping (NSDictionary) -> (), failure: @escaping (Error?) -> ()) {
        
        replyTweetSuccess = success
        replyTweetFailure = failure
        
        var parameters = Dictionary<String, Any>()
        
        parameters["status"] = status
        parameters["in_reply_to_status_id"] = id
        
        post("/1.1/statuses/update.json", parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response) in
            
            let dictionary = response as! NSDictionary
            
            self.replyTweetSuccess?(dictionary)
            
            }, failure: { (task: URLSessionDataTask? , error: Error?) in
                self.replyTweetFailure?(error)
        })
    }

}
