//
//  ViewController.swift
//  FindMyPeeps
//
//  Created by Brock D'Amico on 9/14/15.
//  Copyright (c) 2015 SkyRealm Studios. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //declare UI objects
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    //other variables
    var locationManager: CLLocationManager!
    var latitude: Double!
    var longitude: Double!
    var address: String!
    var comment: String!
    var userLocationAnnotation = CustomPointAnnotation()
    var updateUserLocationOrNot:Bool = false
    
    //useless variables
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize the Location Manager
        locationManager = CLLocationManager()
        
        //setup the swipe gestures
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
        
        //start up the location
        initLocationManager(locationManager)
        
        //get friends locations
        get_marker_script()
        
        //setup mapView delegate
        mapView.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //when updateLocation button is clicked
    @IBAction func button_clicked(sender: AnyObject) {
        //declare variables
        var lastUpdated:String! = String()
        var time:String! = String()
        var commentTextField:UITextField = UITextField()
        updateUserLocationOrNot = true
        
        //create popup dialog
        let alert = UIAlertController(title: "Update Location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField) in
            textField.placeholder = "Status"
            textField.secureTextEntry = true
            commentTextField = textField
        })
        
        self.presentViewController(alert, animated: true, completion: nil)
    
        //adds an update location button to the popup dialog
        alert.addAction(UIAlertAction(title: "Update Location", style: .Default, handler: {(action: UIAlertAction) in
            if (self.latitude != nil && self.longitude != nil && self.address != nil)
            {
            
            //get the comments text
            self.comment = commentTextField.text
            
            //get the date and the time
            let date:NSDate = NSDate()
            let dateFormatter:NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            //format date and save it in todays date
            lastUpdated = dateFormatter.stringFromDate(date)
            time = lastUpdated.substringWithRange(Range(start: lastUpdated.startIndex.advancedBy(11), end: lastUpdated.startIndex.advancedBy(16)))            
            //parses the date
            if(Array(lastUpdated.characters)[0] == "0" && Int(lastUpdated.substringWithRange(Range(start: lastUpdated.startIndex.advancedBy(11), end: lastUpdated.startIndex.advancedBy(13)))) <= 12)
            {
                lastUpdated = lastUpdated + " AM"
                time = time + " AM"
            } else {
                lastUpdated = lastUpdated + " PM"
                time = time + " PM"
            }
            
            //send the asynchronus post
            var bodyData:String
            bodyData = "Latitude=" + String(self.latitude) + "&Longitude=" + String(self.longitude) + "&Username=rockyfish&Address=" + self.address + "&Comments=" + self.comment + "&LastUpdated=" + lastUpdated + "&Number=MTAwMDAwMDEzMw==&Time=" + time;
            let url:NSURL = NSURL(string: "http://www.skyrealmstudio.com/cgi-bin/updatelocation.py")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print(responseString)
            }
                
                //if that users mark is already on the map
            if(self.userLocationAnnotation.title != nil)
            {
                self.mapView.removeAnnotation(self.userLocationAnnotation)
            }
            self.userLocationAnnotation.title = "rockyfish"
            self.userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude)
            self.mapView.addAnnotation(self.userLocationAnnotation)
            } else {
                print("Could not update location")
            }
        }))
        
        //adds a cancel button to the popup dialog
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction) in
        }))
        
    }
    
    //what happens while locations is updating
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        //ask for location and assign variable
        let location: AnyObject? = locations.last
        let loc = location as! CLLocation
        self.latitude = loc.coordinate.latitude
        self.longitude = loc.coordinate.longitude
        //gets the users adddress with a geocoder
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if (error != nil)
            {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            } else {
                let pm = placemarks![0]
                if(pm.subThoroughfare != nil)
                {
                    self.address = pm.subThoroughfare! + " " + pm.thoroughfare!
                }
            }
       
        })
        self.userLocationAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.userLocationAnnotation.title = "rockyfish"
        self.mapView.addAnnotation(self.userLocationAnnotation)
    }
    
    //gets all their friends locations
    func get_marker_script()
    {
        let bodyData:String! = "username=rockyfish&Number=MTAwMDAwMDEzMw=="
        let url:NSURL! = NSURL(string: "http://skyrealmstudio.com/cgi-bin/MarkerScript.py")
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                //get response
                let jsonObject : AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    if let statusesArray = jsonObject as? NSArray
                    {
                        for(var i = 0; i < jsonObject.count; i++)
                        {
                        if let aStatus = statusesArray[i] as? NSDictionary
                        {
                            let user: String = String(aStatus["Username"]!)
                            let lat: Double? = aStatus["Latitude"]?.doubleValue
                            let long: Double? = aStatus["Longitude"]?.doubleValue
                            let comm: String = String(aStatus["Comment"]!)
                            let lastUpdated: String = String(aStatus["LastUpdated"]!)
                            let description: String = lastUpdated.substringWithRange(Range(start: lastUpdated.startIndex.advancedBy(5), end: lastUpdated.startIndex.advancedBy(16))) + lastUpdated.substringWithRange(Range(start: lastUpdated.startIndex.advancedBy(20), end: lastUpdated.startIndex.advancedBy(22))) + " - " + comm
                            
                            let annotation:CustomPointAnnotation = CustomPointAnnotation()
                            annotation.title = String(user)
                            annotation.subtitle = description
                            annotation.urlName = "http://www.skyrealmstudio.com/img/" + user.lowercaseString + ".jpg"
                            annotation.coordinate = CLLocationCoordinate2DMake(lat!, long!)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.mapView.addAnnotation(annotation)

                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
        }
    }
    
    //when a swipe handle is called
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("FriendsView")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    //sets the view up for the annotation to have a button
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            
            let selectedLoc = view.annotation
            
            print("Annotation '\(selectedLoc!.title!)' has been selected")
            
            let currentLocMapItem = MKMapItem.mapItemForCurrentLocation()
            
            let selectedPlacemark = MKPlacemark(coordinate: selectedLoc!.coordinate, addressDictionary: nil)
            let selectedMapItem = MKMapItem(placemark: selectedPlacemark)
            
            let mapItems = [selectedMapItem, currentLocMapItem]
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            
            MKMapItem.openMapsWithItems(mapItems, launchOptions:launchOptions)
    }

    //sets the pictures on the map from a url
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var trueOrFalse:Bool = false
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "Profile Picture"

        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
            anView!.rightCalloutAccessoryView = UIButton(type: .InfoDark)
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        let cpa = annotation as! CustomPointAnnotation
            if(cpa.urlName != nil)
            {
                let url:NSURL = NSURL(string: cpa.urlName)!
                if let data = NSData(contentsOfURL: url){
                    anView!.image =  UIImage(data: data)
                }
            }
            else
            {
                anView!.image = UIImage(named: "action_logo")
                trueOrFalse = true
            }
        
        
        //resize the users friends profile pictures
        var cropSquare = CGRectMake(0, 0, anView!.image!.size.width / 4, anView!.image!.size.height / 4)
        if(trueOrFalse)
        {
            cropSquare = CGRectMake(0, 0, anView!.image!.size.width, anView!.image!.size.height)
        }
        UIGraphicsBeginImageContextWithOptions(cropSquare.size, false, 1.0)
        anView!.image!.drawInRect(cropSquare)
        anView!.image = UIGraphicsGetImageFromCurrentImageContext()
       
        
        //make the images circles
        let imageView: UIImageView = UIImageView(image: anView!.image)
        var layer: CALayer = CALayer()
        layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(anView!.image!.size.width / 2)
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        anView!.image = roundedImage
        UIGraphicsEndImageContext()
        
        return anView
}
    
    //initializes the locationManager
    func initLocationManager(locationManager: CLLocationManager){
        // Ask for Authorisation from the User
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        //if location is enabled and the request was accepted
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //once map has finished rendering
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        if(self.firstLoad == true)
        {
            mapView.showAnnotations(self.mapView.annotations, animated: false)
            self.mapView.userInteractionEnabled = true
        }
        self.firstLoad = false
    }
}

//class for setting the url name, it is a child of MkPointAnnotation
class CustomPointAnnotation: MKPointAnnotation {
    var urlName: String!
}

