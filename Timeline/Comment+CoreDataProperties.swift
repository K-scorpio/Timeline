//
//  Comment+CoreDataProperties.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Comment {

    @NSManaged var timestamp: NSDate?
    @NSManaged var text: String?
    @NSManaged var post: Post?

}
