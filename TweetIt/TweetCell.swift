//
//  TweetCell.swift
//  TweetIt
//
//  Created by Quoc Huy on 10/29/16.
//  Copyright © 2016 HuyPhung. All rights reserved.
//

import UIKit
import Foundation

@objc protocol TweetCellDelegate {
    @objc optional func tweetCell(tweetCell: TweetCell, didUpdateId id: Int)
}

class TweetCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var lightButton: UIButton!
    @IBOutlet weak var lightImage: UIImageView!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    
    // Variable used for the delegate
    weak var delegate: TweetCellDelegate?
    
    // Variable use to get ID  string of the tweet
    var idStr: String!
    
    var tweet: Tweet! {
        didSet{
            if tweet.userUrl != nil {
                userImage.setImageWith(tweet.userUrl!)
            }
            
            userNameLabel.text = tweet.userName
            tweetTextLabel.text = tweet.text
            
            let favorited = tweet.favorited! as Bool
            if favorited {
                lightImage.image = #imageLiteral(resourceName: "lightOn")
            } else {
                lightImage.image = #imageLiteral(resourceName: "lightOff")
            }
            
            let favoritesCount = Double(tweet.favoritesCount)
            let favoritesCountStr = formatPoints(num: favoritesCount)
            
            favoritesCountLabel.text = favoritesCountStr
            
            idStr = tweet.idStr
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onLight(_ sender: UIButton) {
        
        let idInt = Int(idStr!)
        print("[INFO] My tweet id = \(idInt)")
        
        delegate?.tweetCell!(tweetCell: self, didUpdateId: idInt!)
        
    }
    
}

// Cover 1000 -> k 1000000 -> m
func formatPoints(num: Double) ->String{
    
    // Format the decimal point
    let myFormatter = NumberFormatter()
    myFormatter.decimalSeparator = "."
    myFormatter.minimumFractionDigits = 2
    myFormatter.minimumIntegerDigits  = 1
    
    let thousandNum = num/1000
    let millionNum = num/1000000
    
    if num >= 1000 && num < 1000000{
        let thousandNumStr = myFormatter.string(from: NSNumber(value: thousandNum))
        return("\(thousandNumStr!)k")
    }
    else if num > 1000000 {
        let millionNumStr = myFormatter.string(from: NSNumber(value: millionNum))
        return("\(millionNumStr!)m")
    }
    else{
        return ("\(Int(num))")
    }
    
}
