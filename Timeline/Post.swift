//
//  Post.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit
import CoreData


class Post: NSManagedObject {
    
    private let timestampKey = "timestamp"
    private let photoDataKey = "photoData"
    
    convenience init?(photo: NSData, timestamp: NSDate, caption: String, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            return nil
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
    }
    
    var photo: UIImage? {
        
        let photoData = self.photoData
        
        return UIImage(data: photoData)
    }
}
