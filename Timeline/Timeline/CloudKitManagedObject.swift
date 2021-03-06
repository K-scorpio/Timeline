//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/9/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import Foundation

import CoreData
import CloudKit

@objc protocol CloudKitManagedObject {
    
    var timestamp: NSDate { get set }
    var recordIDData: NSData? { get set }
    var recordName: String { get set }
    var recordType: String { get set }
    var cloudKitRecord: CKRecord? { get }
    
}

extension CloudKitManagedObject {
    var isSynced: Bool {
        return recordIDData != nil
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDData = recordIDData,
            let recordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID else {
                return nil
        }
        return recordID
    }
    
    func update(record: CKRecord) {
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save MOC: \(error)")
        }
    }
    
    var cloudKitReference: CKReference? {
        guard let recordID = cloudKitRecordID else { return nil }
        return CKReference(recordID: recordID, action: .None)
    }
    
    func nameForManagedObject() -> String {
        return NSUUID().UUIDString
    }
}