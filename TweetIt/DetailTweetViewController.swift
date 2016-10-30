//
//  DetailTweetViewController.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/30/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit

class DetailTweetViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var lightImage: UIImageView!
    @IBOutlet weak var retweetImage: UIImageView!
    
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    // Variable to store favorite status
    var favorited: Bool?
    
    // Variable to store retweet status
    var retweeted: Bool?
    
    // Variable to store tweet ID
    var id: Int?
    
    // Variable to store default tweet ID
    var default_id: Int?
    
    // Variable used to transfer one business from segue
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change titleView to white color
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Change the color of Navigation Bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 100/255, green: 221/255, blue: 23/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        let idStr = tweet.idStr
        default_id = Int(idStr!)
        
        setTweetDetails()

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For reply tweet view
        if (segue.identifier == "replyTweetSegue") {
            let navController = segue.destination as! UINavigationController
            let filterVC = navController.topViewController as! ReplyViewController
            
            filterVC.delegate = self
        }
        
    }

    // Function to create or destroy favorite
    @IBAction func onFavorite(_ sender: UIButton) {
        // New client
        let client = TwitterClient.sharedInstance
        
        if favorited! {
            client?.destroyFavorite(id: id!, success: { (response: NSDictionary) in
                
                let tweetResponse = Tweet(dictionary: response)
                print("[INFO] Destroy Favorite in tweetID:  \(tweetResponse.idStr)")
                
                self.tweet = tweetResponse
                self.setTweetDetails()
                
                self.reloadInputViews()
                
            }, failure: { (error: Error?) in
                    print("[ERROR] Destroy favorite fail: \(error?.localizedDescription)")
            })
        } else {
            client?.createFavorite(id: id!, success: { (response: NSDictionary) in
                
                let tweetResponse = Tweet(dictionary: response)
                print("[INFO] Create Favorite in tweetID:  \(tweetResponse.idStr)")
                
                self.tweet = tweetResponse
                self.setTweetDetails()
                
                self.reloadInputViews()
                
            }, failure: { (error: Error?) in
                    print("[ERROR] Create favorite fail: \(error?.localizedDescription)")
            })
        }
    }
    
    // Function to retweet or unretweet
    @IBAction func onRetweet(_ sender: UIButton) {
        // New client
        let client = TwitterClient.sharedInstance
        
        if retweeted! {
            client?.doUnRetweet(id: id!, success: { (response: NSDictionary) in
                
                let tweetResponse = Tweet(dictionary: response)
                print("[INFO] UnRetweet in tweetID:  \(tweetResponse.idStr)")
                
                self.tweet = tweetResponse
                
                self.setTweetDetails()
                
                client?.doUnRetweet(id: self.id!, success: { (response: NSDictionary) in
                    
                    let tweetResponse = Tweet(dictionary: response)
                    
                    self.tweet = tweetResponse
                    self.setTweetDetails()
                    
                    self.reloadInputViews()
                    
                }, failure: { (error: Error?) in
                        print("[ERROR] UnRetweet fail: \(error?.localizedDescription)")
                })
                
                
            }, failure: { (error: Error?) in
                    print("[ERROR] UnRetweet fail: \(error?.localizedDescription)")
            })
        } else {
            
            client?.doRetweet(id: id!, success: { (response: NSDictionary) in
                
                let tweetResponse = Tweet(dictionary: response)
                print("[INFO] Retweet in tweetID:  \(tweetResponse.idStr)")
                
                // The reponse here is special -> Do not load the user info
                self.tweet.retweetCount = tweetResponse.retweetCount
                self.tweet.retweeted = tweetResponse.retweeted
                
                self.setTweetDetails()
                
                self.reloadInputViews()
                
            }, failure: { (error: Error?) in
                    print("[ERROR] Retweet fail: \(error?.localizedDescription)")
            })
        }
    }
    
    
    
    
    // Function to set the image, label of detail view
    func setTweetDetails() {
        if tweet.userUrl != nil {
            userImage.setImageWith(tweet.userUrl!)
        }
        
        nameLabel.text = tweet.userName
        screenNameLabel.text =  tweet.screenName
        
        textLabel.text = tweet.text
        
        favorited = tweet.favorited! as Bool
        if favorited! {
            lightImage.image = #imageLiteral(resourceName: "lightOn")
        } else {
            lightImage.image = #imageLiteral(resourceName: "lightOff")
        }
        
        retweeted = tweet.retweeted! as Bool
        if retweeted! {
            retweetImage.image = #imageLiteral(resourceName: "shareOn")
        } else {
            retweetImage.image = #imageLiteral(resourceName: "shareOff")
        }
        
        let favoritesCount = Double(tweet.favoritesCount)
        let favoritesCountStr = formatPoints(num: favoritesCount)
        
        favoritesCountLabel.text = favoritesCountStr
        
        let retweetCount = Double(tweet.retweetCount)
        let retweetCountStr = formatPoints(num: retweetCount)
        
        retweetCountLabel.text = retweetCountStr
        
        let idStr = tweet.idStr
        id = Int(idStr!)

    }
    
}

// Function and delegate for posting new tweet
extension DetailTweetViewController: ReplyViewControllerDelegate {
    
    // Delegate used to catch the signal from filter view
    func replyViewController(replyViewController: ReplyViewController, didUpdateStatus status: String) {
        let client = TwitterClient.sharedInstance
        
        let screenname = "@" + tweet.screenName! + " " as String
        let replyStatus = screenname + status as String
        
        client?.replyTweet(status: replyStatus, id: default_id!, success: { (dictionary: NSDictionary) in
            
            let text = dictionary["text"] as! String
            print("[INFO] Posted:  \(text)")
            
            //self.loadTweets()
            
            }, failure: { (error: Error?) in
                print("[ERROR] Posted fail: \(error?.localizedDescription)")
        })
        
    }
    
}
