//
//  TweetsViewController.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/29/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit
import Social

class TweetsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Variable to check the load finish
    // var checkSamplingFinish = false
    
    // Variable used for tweets
    var tweetssample: [Tweet]!
    
    // Initialize a UIRefreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
        
        // Automatic change the height of row to fit the context
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Change titleView to white color
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Change the color of Navigation Bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 100/255, green: 221/255, blue: 23/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // Load tweets
        loadTweets()
        
        refreshControl.addTarget(self, action: #selector(TweetsViewController.loadTweets), for: UIControlEvents.valueChanged)
        // Add refresh control to table view or grid view
        tableView.insertSubview(refreshControl, at: 0)
        
    }
    
    @IBAction func onLogOut(_ sender: UIBarButtonItem) {
        // Save key to track login or logout
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: "logKey")
        print("[INFO] Set logKey = false")
        defaults.synchronize()
        
        TwitterClient.sharedInstance?.logOut()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // For new tweet view
        if (segue.identifier == "newTweetSegue") {
            let navController = segue.destination as! UINavigationController
            let filterVC = navController.topViewController as! NewTweetViewController
            
            filterVC.delegate = self
        }
        // For detail view
        else {
            let ip = tableView.indexPathForSelectedRow
            let detailVC = segue.destination as! DetailTweetViewController
            detailVC.tweet = self.tweetssample[(ip?.row)!]
            
        }
        
    }

}

// Table view data source and delegate
extension TweetsViewController: UITableViewDelegate, UITableViewDataSource, TweetCellDelegate {
    
    // Function used to set the number of row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweetssample != nil {
            return tweetssample.count
        } else {
            return 0
        }
        
    }
    
    // Function used to cast the business cell from API or search
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
        
        cell.tweet = tweetssample[indexPath.row]
        
        cell.delegate = self
        
        return cell
        
    }
    
    // Function used to deselect the selected row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Tweet cell delegate
    func tweetCell(tweetCell: TweetCell, didUpdateId id: Int) {
        
        // New client
        let client = TwitterClient.sharedInstance
        
        // Get the indexpath
        let ip = tableView.indexPath(for: tweetCell)
        
        // Boolean value to store favorite state
        var favorited: Bool?
        
        favorited = tweetssample[(ip?.row)!].favorited
        
        if favorited! {
            client?.destroyFavorite(id: id, success: { (response: NSDictionary) in
                
                let tweetIdStr = response["id_str"] as! String
                print("[INFO] Destroy Favorite in tweetID:  \(tweetIdStr)")
                for tweet in self.tweetssample {
                    if tweet.idStr == tweetIdStr {
                        let tweetResponse = Tweet(dictionary: response)
                        tweet.favorited = tweetResponse.favorited
                        tweet.favoritesCount = tweetResponse.favoritesCount
                        tweet.retweetCount = tweetResponse.retweetCount
                        tweet.userUrl = tweetResponse.userUrl
                        tweet.userName = tweetResponse.userName
                        tweet.text = tweetResponse.text
                        tweet.timeStamp = tweetResponse.timeStamp
                        
                    }
                    
                }
                self.tableView.reloadData()
                
            }, failure: { (error: Error?) in
                    print("[ERROR] Destroy favorite fail: \(error?.localizedDescription)")
            })
        } else {
            client?.createFavorite(id: id, success: { (response: NSDictionary) in
                
                let tweetIdStr = response["id_str"] as! String
                print("[INFO] Create Favorite in tweetID:  \(tweetIdStr)")
                for tweet in self.tweetssample {
                    if tweet.idStr == tweetIdStr {
                        let tweetResponse = Tweet(dictionary: response)
                        tweet.favorited = tweetResponse.favorited
                        tweet.favoritesCount = tweetResponse.favoritesCount
                        tweet.retweetCount = tweetResponse.retweetCount
                        tweet.userUrl = tweetResponse.userUrl
                        tweet.userName = tweetResponse.userName
                        tweet.text = tweetResponse.text
                        tweet.timeStamp = tweetResponse.timeStamp
                        
                    }
                    
                }
                self.tableView.reloadData()
 
            }, failure: { (error: Error?) in
                    print("[ERROR] Create favorite fail: \(error?.localizedDescription)")
            })
        }
        
        print("[INFO] TweetsViewController got signal from Tweet cell")
        
    }
    
}

// Function for TwitterClient
extension TweetsViewController {
    
    // Load Tweets
    func loadTweets() {
        let client = TwitterClient.sharedInstance
        
        client?.homeTimeline(success: { (tweets: [Tweet]) in
            self.tweetssample = tweets
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            
        }, failure: { (error: Error?) in
                print("[ERROR] Load tweet fail: \(error?.localizedDescription)")
                self.refreshControl.endRefreshing()
        })
    }
    
    
    
}

// Function and delegate for posting new tweet
extension TweetsViewController: NewTweetViewControllerDelegate {
    
    // Delegate used to catch the signal from filter view
    func newTweetViewController(newTweetViewController: NewTweetViewController, didUpdateStatus status: String) {
        let client = TwitterClient.sharedInstance
        
        client?.postTweet(status: status, success: { (dictionary: NSDictionary) in
            
            let text = dictionary["text"] as! String
            print("[INFO] Posted:  \(text)")
            
            self.loadTweets()
            
        }, failure: { (error: Error?) in
                print("[ERROR] Posted fail: \(error?.localizedDescription)")
        })
        
    }
    
}
