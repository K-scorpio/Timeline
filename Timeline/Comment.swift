//
//  Comment.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import Foundation
import CoreData


class Comment: NSManagedObject {

    convenience init?(post: Post, text: String, timestamp: NSDate, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            return nil
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
    }
}
