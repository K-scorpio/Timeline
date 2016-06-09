//
//  Post.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit
import CoreData
import CloudKit


class Post: NSManagedObject, CloudKitManagedObject {
    
    private let timestampKey = "timestamp"
    private let photoDataKey = "photoData"
    
    convenience init(photo: NSData, timestamp: NSDate, caption: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError("Error: Core Data failed to create entity from entity description")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
        self.recordName = self.managedObjectContext
    }
    
    var photo: UIImage? {
        
        let photoData = self.photoData
        
        return UIImage(data: photoData)
    }
    
    
}
