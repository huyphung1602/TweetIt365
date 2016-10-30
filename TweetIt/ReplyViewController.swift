//
//  ReplyViewController.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/31/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit

@objc protocol ReplyViewControllerDelegate {
    @objc optional func replyViewController(replyViewController: ReplyViewController, didUpdateStatus status: String)
}

class ReplyViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textFieldView: UITextView!

    // Variable used for the delegate
    weak var delegate: ReplyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change titleView to white color
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // Change the color of Navigation Bar
        navigationController?.navigationBar.barTintColor = UIColor(red: 100/255, green: 221/255, blue: 23/255, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // Load current user info
        loadCurrentUser()
        
        textFieldView.becomeFirstResponder()
        
    }

    // Cancel reply tweet
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Post reply tweet
    @IBAction func onPost(_ sender: UIBarButtonItem) {
        let status = textFieldView.text as String
        
        if status != "" {
            delegate?.replyViewController!(replyViewController: self, didUpdateStatus: status)
        } else {
            print("[INFO] Blank -> No new tweet")
        }
        
        dismiss(animated: true, completion: nil)
    }
    

}

// Function for loading current user info
extension ReplyViewController {
    func loadCurrentUser() {
        let client = TwitterClient.sharedInstance
        
        client?.currentAccount(success: { (user: User?) in
            
            self.nameLabel.text = user?.name
            self.screenNameLabel.text = user?.screenName
            
            if user?.profileUrl != nil {
                self.userImage.setImageWith((user?.profileUrl)!)
            }
            
            self.reloadInputViews()
            
            }, failure: { (error: Error?) in
                print("[ERROR] \(error?.localizedDescription)")
        })
    }
}
