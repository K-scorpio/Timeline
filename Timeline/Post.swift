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


class Post: NSManagedObject, CloudKitManagedObject, SearchableRecord {
    
    private let timestampKey = "timestamp"
    private let photoDataKey = "photoData"
    
    convenience init(photo: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError("Error: Core Data failed to create entity from entity description")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photo
        self.timestamp = timestamp
        self.recordName = self.nameForManagedObject()
    }
    
    var photo: UIImage? {
        
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    lazy var temporaryPhotoURL: NSURL = {
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
        self.photoData?.writeToURL(fileURL, atomically: true)
        return fileURL
    }()
    
    //MARK: - Cloud Kit MOC
    
    var recordType: String = "Post"
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[timestampKey] = timestamp
        record[photoDataKey] = CKAsset(fileURL: temporaryPhotoURL)
        
        return record
    }
    
    convenience init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        guard let timestamp = record.creationDate,
            let photoData = record["photoData"] as? CKAsset else {
                return nil
        }
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError("AHHHHHHH!!!!!!")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.timestamp = timestamp
        self.photoData = NSData(contentsOfURL: photoData.fileURL)
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
        
    }
    
    func updateWithRecord(record: CKRecord) {
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record)
    }
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if let comments = self.comments.array as? [Comment] {
            let filteredComments = comments.filter({$0.matchesSearchTerm(searchTerm)})
            return filteredComments.count > 0
        } else {
            return false
        }
    }
}
