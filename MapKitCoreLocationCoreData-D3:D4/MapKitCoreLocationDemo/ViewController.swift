//
//  ViewController.swift
//  MapKitCoreLocationDemo
//
//  Created by Victor  Adu on 8/18/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var longFiled: UITextField!
    
    var myContext : NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
        case .Authorized:
            println("You are authorized. Awesome")
        case .NotDetermined:
            println("This must be your first launch")
            self.locationManager.startUpdatingLocation()
            
        case .Restricted:
            println("This device is restricted from accessing core location")
        case .AuthorizedWhenInUse:
            println("authorized when in use")
            //when were authorized, show user location and start updating locations
            self.mapView.showsUserLocation = true
            
            //this one is for the high power, standard location services
            //self.locationManager.startUpdatingLocation()
            
            //this is the significant location monitoring, will only fire when location changes > 500 meters
            //self.locationManager.startMonitoringSignificantLocationChanges()
            
        case .Denied:
            println("You've denied Location Service on this device. To change this, kindly check your Settings")
        
        }
        
        println(CLLocationManager.authorizationStatus().toRaw())
        
        //setup our longpress gesture recognizer
                var longPress = UILongPressGestureRecognizer(target: self, action: "mapPressed:")
                self.mapView.addGestureRecognizer(longPress)
                self.mapView.delegate = self
        
        //Reference to our app delegate
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //Reference NSManagedObjectContext (MOC)
        self.myContext = appDelegate.managedObjectContext
        
         // Do any additional setup after loading the view, typically from a nib.
    }
    
    func mapPressed(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            println("Began")
            //Figuring out where user  touched on mapView
            var touchPoint = sender.locationInView(self.mapView)
            var touchCordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            //Setting up our pin
            var annotation = MKPointAnnotation()
            annotation.coordinate = touchCordinate
            annotation.title = "Add Reminder"
            self.mapView.addAnnotation(annotation)
            
        case .Changed:
            println("Changed")
        case .Ended:
            println("Ended")
            
            var touchPoint = sender.locationInView(self.mapView)
            var touchCordinate = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            //Configuring and returning an instance of a new entity of 'Reminder' using the 'insertNewObjectForEntityForName' method
            var newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.myContext) as Reminder
            newReminder.latitude = touchCordinate.latitude
            newReminder.longitude = touchCordinate.longitude
            newReminder.messageLocation = "Swipe to Add Location name"
            println(newReminder.latitude)
            println(newReminder.longitude)
            
            var error : NSError?
            self.myContext.save(&error)
            if error != nil{
                println(error?.localizedDescription)
            }
            
            //Segue to display our reminder on our tableView
            self.performSegueWithIdentifier("showReminder", sender: self)
            
        default:
            println("default")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //'ResignFirstResponder' collapses keyboard when user hits 'Return/Enter/Done'
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func locateBtnPressed(sender: AnyObject) {
        
        var latString = NSString(string: self.latField.text)
        var lat = latString.doubleValue
        
        var longString = NSString(string: self.longFiled.text)
        var long = longString.doubleValue
        
        var newLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        var region = MKCoordinateRegionMakeWithDistance(newLocation, 1000, 1000)
        
        self.mapView.setRegion(region, animated: true)
        
        //Also, lets segue to our 'DetailtableView' SB when button is clicked
        self.performSegueWithIdentifier("showReminder", sender: self)
    }
    
    @IBAction func showReminderBtnPressed(sender: AnyObject) {
        //Also, lets segue to our 'DetailtableView' SB when button is clicked
        self.performSegueWithIdentifier("showReminder", sender: sender)
    }
    
    
    //Setup annotation Method to drop Pin
    func setupAnnotationView(annotationView : MKPinAnnotationView) {
        annotationView.animatesDrop = true
        annotationView.canShowCallout = true
        //Configure Callout
        var rightButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
        annotationView.rightCalloutAccessoryView  = rightButton
        
    }
    
    //MARK: MKMapViewDeleGate Methods
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        //The commands here is very similar to tableView's 'cellForRowAtIndexPath' method'
        
        //First we will try to dequeue old annotation pin
        if let annotationVw = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
            //if we didn't get any pin back, create a new one with identifier
            self.setupAnnotationView(annotationVw)
            return annotationVw
        } else {
            var annotationVw = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            self.setupAnnotationView(annotationVw)
            return annotationVw
        }
    }
    
//    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
//        //Tells us which annotation was clicked
//        var annotation = view.annotation
//        
//        var geoRegion = CLCircularRegion(center: annotation.coordinate, radius: 200, identifier: "Reminder") //We could use any name as our 'identifier' here.
//        self.locationManager.startMonitoringForRegion(geoRegion)
//        
//        println(annotation.coordinate.latitude)
//        println(annotation.coordinate.longitude)
//        
//    }
    
    
    //MARK: CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            println("User Authorization accepted by user")
            self.mapView.showsUserLocation = true
            self.locationManager.startUpdatingLocation()
        case .Denied:
            println("Denied Access by user")
        case .AuthorizedWhenInUse:
            println("User has authorized while app is in use.")
            self.mapView.showsUserLocation = true
        default:
            println("auth did change, default")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("location did update")
        
        if let location = locations.last as? CLLocation {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
        }
    }
    //Listen for entering region
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) { ///
        println("Did Enter region")
    }
    //Listen for exiting region
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {  ///
        println("did exit region")
    }
}

