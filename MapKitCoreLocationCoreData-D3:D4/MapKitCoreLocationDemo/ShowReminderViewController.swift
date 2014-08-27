//
//  ShowReminderViewController.swift
//  MapKitCoreLocationDemo
//
//  Created by Victor  Adu on 8/20/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import UIKit
import CoreData

class ShowReminderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController : NSFetchedResultsController!
    var myContext : NSManagedObjectContext!

    @IBOutlet weak var tableView: UITableView!
    
    var indexPath : NSIndexPath?

    
    // var indexPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the MoC from app delegate
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.myContext = appDelegate.managedObjectContext
        
        //Setup the fetched results controller
        var request = NSFetchRequest(entityName: "Reminder")
        let sort = NSSortDescriptor(key: "messageLocation", ascending: true)
        
        //Add sort to the request
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        //Initialize the 'fetchedResultsController'
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.myContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController.delegate = self
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        //Perform fetch on appearance of window screen
        var error : NSError?
        fetchedResultsController.performFetch(&error)
        if error != nil {
            println("Error fetching Reminders: \(error?.localizedDescription)")
        }
    }

    //MARK: - TableViewDataSource Methods
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController!.sections[section].numberOfObjects
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("reminderCell", forIndexPath: indexPath) as ShowReminderTBCell
        self.configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    //Here we just took the statements that goes within 'cellForRowAtIndexPath' and put it in a function
    func configureCell(cell: UITableViewCell, forIndexPath indexPath: NSIndexPath) {
        var label = self.fetchedResultsController.fetchedObjects[indexPath.row] as Reminder
        cell.textLabel.text = label.messageLocation
    } // edit decimal places if you have time.
    
    //Allows us to reorder cell rows
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    //MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //TableView other options (Delete/Edit/More)
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        // don't need anything here, just implement to make it work
    }
    
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        // create a delete action
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") {
            (action, indexPath) in
            // implement the delete changes
            if let reminderRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as? Reminder {
                self.myContext.deleteObject(reminderRow)
                self.myContext.save(nil)
            }
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit Reminder") { (action:UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            if let reminderRow = self.fetchedResultsController.fetchedObjects[indexPath.row] as? Reminder {
            self.indexPath = indexPath
            self.performSegueWithIdentifier("editReminderDetails", sender: self)    ///
        }
    }
        //We could add 'moreAction' tabs if we want...
//        let moreAction = UITableViewRowAction(style: .Default, title: "More") { (action, indexPath) -> Void in
//            println("More Action Tapped")
//        }
        
        // set the background color for the action button
        deleteAction.backgroundColor = UIColor.redColor()
        editAction.backgroundColor = UIColor.lightGrayColor()
        //moreAction.backgroundColor = UIColor.lightGrayColor()
        
        // return an array of actions
        return [deleteAction, editAction]
    }
    
    //MARK: - NSFetchedResultsControllerDelegate Methods
    
    // called when an object is about to change
    func controllerWillChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.beginUpdates()
    }
    
    // called after a change is committed
    func controllerDidChangeContent(controller: NSFetchedResultsController!) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController!, didChangeObject anObject: AnyObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
//            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath), forIndexPath: indexPath)
            var cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath) as ShowReminderTBCell
            self.configureCell(cell, forIndexPath: indexPath)
            
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
    }

    
    //MARK: - PrepareForSegue Methods
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "editReminderDetails" {
            
            var editReminderVC = segue.destinationViewController as EditReminderDetailsViewController
            var reminder = self.fetchedResultsController.fetchedObjects[self.indexPath!.row] as Reminder
            editReminderVC.reminderEdit = reminder
            self.tableView.deselectRowAtIndexPath(self.indexPath!, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
