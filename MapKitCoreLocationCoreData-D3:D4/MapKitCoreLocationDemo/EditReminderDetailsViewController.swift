//
//  EditReminderDetailsViewController.swift
//  MapKitCoreLocationDemo
//
//  Created by Victor  Adu on 8/24/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import CoreData

class EditReminderDetailsViewController: UIViewController {
    

    @IBOutlet weak var messageLocationTextField: UITextField!
    
    var reminderEdit : Reminder!
    
    var myContext : NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.myContext = appDelegate.managedObjectContext
        
        self.messageLocationTextField.text = self.reminderEdit.messageLocation
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func saveReminderBtnPressed(sender: AnyObject) {
        
        reminderEdit.messageLocation = self.messageLocationTextField.text
        reminderEdit.managedObjectContext.save(nil)
        self.navigationController.popViewControllerAnimated(true)
        
        
    }
    
    //'ResignFirstResponder' collapses keyboard when user hits 'Return/Enter/Done'
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
}
