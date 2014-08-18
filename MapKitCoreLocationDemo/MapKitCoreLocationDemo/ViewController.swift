//
//  ViewController.swift
//  MapKitCoreLocationDemo
//
//  Created by Victor  Adu on 8/18/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var longFiled: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //creating a region at the start (instantiating the 'mapView' on the screen)
      /*  var location = CLLocationCoordinate2D(latitude: 47.6, longitude: -122.3)
        self.mapView.region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000) */
        
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
            println("Fire an alertView, pleading with the user about turning it on")
        
        }
        
        self.latField.delegate = self
        self.longFiled.delegate = self
        
        var ground = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0444)
        var eye = CLLocationCoordinate2D(latitude: 40.6892, longitude: -74.0444) // What's the difference b/n eye n ground???
        
        var camera = MKMapCamera(lookingAtCenterCoordinate: ground, fromEyeCoordinate: eye, eyeAltitude: 50)
        self.mapView.camera = camera
        
        //setup our pan gesture recognizer
        var pan = UIPanGestureRecognizer(target: self, action: "mapPanned:")
        self.view.addGestureRecognizer(pan)
        
        //setup our longpress gesture recognizer
        //        var longPress = UILongPressGestureRecognizer(target: self, action: "mapPressed:")
        //        self.mapVIew.addGestureRecognizer(longPress)
        
        // Do any additional setup after loading the view, typically from a nib.
   
    
    }


    func mapPanned(sender : UIPanGestureRecognizer) {
        
        switch sender.state {
        case .Changed:
            var point = sender.translationInView(self.view)
            println(point)
        default:
            println("default")
        }
        
    }
    
  /*  func mapPressed(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .Began:
            println("Began")
        case .Changed:
            println("Changed")
        case .Ended:
            println("Ended")
        default:
            println("default")
        }
        
    }     */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
        
    }

}

