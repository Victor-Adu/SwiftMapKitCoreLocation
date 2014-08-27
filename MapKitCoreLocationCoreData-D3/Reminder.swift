//
//  Reminder.swift
//  MapKitCoreLocationDemo
//
//  Created by Victor  Adu on 8/20/14.
//  Copyright (c) 2014 Victor  Adu. All rights reserved.
//

import Foundation
import CoreData

class Reminder: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var messageLocation: String

}
