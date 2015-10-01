//
//  ViewController.swift
//  FindMyPeeps
//
//  Created by Brock D'Amico on 9/14/15.
//  Copyright (c) 2015 SkyRealm Studios. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class FriendsViewController: UITableViewController {
    
    //setup the UI variables
    @IBOutlet var friendsTable: UITableView!
    var friendsList:[String]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        swipeLeft.direction = .Left
        swipeRight.direction = .Right
        
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        
        //get the friends list
        get_friends_list()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //handles the swipes
    func handleSwipes(sender:UISwipeGestureRecognizer)
    {
        if (sender.direction == .Left)
        {
            
        }
        
        if (sender.direction == .Right)
        {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("MapView")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    //get friends list (asynchronus)
    func get_friends_list()
    {
        let bodyData:String = "username=rockyfish&Number=MTAwMDAwMDEzMw=="
        let url:NSURL = NSURL(string: "http://www.skyrealmstudio.com/cgi-bin/GetFriendsList.py")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        //make the asynchronus call
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                let jsonObject : AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if let statusesArray = jsonObject as? NSArray
                {
                    for(var i = 0; i < statusesArray.count; i++)
                    {
                        if let aStatus = statusesArray[i] as? NSDictionary
                        {
                            let friend: String = String(aStatus["friend"]!)
                            //add the friends to a list
                            self.friendsList.append(friend)
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    //setup the datasource
                    self.friendsTable.dataSource = self
                }
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    //called when UITable is set to delegate
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRect(x:0, y:0, width:200, height:50))
        label.text = String(friendsList[indexPath.item])
        cell.addSubview(label)
        return cell
    }

}
