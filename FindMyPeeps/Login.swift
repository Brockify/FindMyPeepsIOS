//
//  Login.swift
//  FindMyPeeps
//
//  Created by Andrew Martin on 9/30/15.
//  Copyright © 2015 SkyRealm Studios. All rights reserved.
//

import Foundation
import UIKit

class Login: UITableViewController {
    //Declare UI Variables
    @IBOutlet weak var UsernameIn: UITextField!
    @IBOutlet weak var Passwordin: UITextField!
    @IBOutlet weak var BLogin: UIButton!
    @IBOutlet weak var BRegister: UIButton!
    @IBOutlet weak var BForgotpassword: UIButton!
    @IBOutlet weak var Remember: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup the swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        swipeLeft.direction = .Left
        swipeRight.direction = .Right
        
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func BLogin(sender: AnyObject) {
        //send the asynchronus post
        var bodyData:String
        bodyData = "username="+self.UsernameIn.text!+"&password="+self.Passwordin.text!
        let url:NSURL = NSURL(string: "http://skyrealmstudio.com/cgi-bin/login.py")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(responseString)
        }

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

    
}
