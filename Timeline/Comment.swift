//
//  Comment.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import Foundation
import CoreData
import CloudKit


class Comment: NSManagedObject, CloudKitManagedObject {
    
    private let textKey = "text"
    private let timestampKey = "timestamp"
    private let postKey = "post"

    convenience init(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError("Error initializing comment")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
        self.recordName = nameForManagedObject()
    }
    
    //MARK: - Implementing CloudKitManagedObject
    
    var recordType: String = "Comment"
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[textKey] = text
        record[timestampKey] = timestamp
        
        guard let post = post,
        let postRecord = post.cloudKitRecord else {fatalError("Comment doesn't have a post relationship")}
        record[postKey] = CKReference(record: postRecord, action: .DeleteSelf)
        return record
    }
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let timestamp = record.creationDate,
            let text = record["text"] as? String,
            let postReference = record["post"] as? CKReference else {
                return nil
        }
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError("Error Saving to managed context")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.timestamp = timestamp
        self.text = text
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName

        self.post = PostController.sharedInstance.postWithName(postReference.recordID.recordName)
    }
    
    func updateWithRecord(record: CKRecord) {
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
    }
}
