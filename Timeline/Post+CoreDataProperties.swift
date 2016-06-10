//
//  Post+CoreDataProperties.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/9/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Post {

    @NSManaged var photoData: NSData?
    @NSManaged var timestamp: NSDate
    @NSManaged var recordIDData: NSData?
    @NSManaged var recordName: String
    @NSManaged var comments: NSOrderedSet

}
