//
//  LoginViewController.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/25/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        let client = TwitterClient.sharedInstance
        
        client?.login(success: { () -> () in
            print("[INFO] I've logged in!")
            
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            
        }, failure: { (error: Error?) in
            print("[ERROR] \(error?.localizedDescription)")
        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
