//
//  CloudKitManager.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/8/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class CloudKitManager {
    
    let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
    let privateDatabase = CKContainer.defaultContainer().privateCloudDatabase
    
    func fetchLoggedInUserRecord(completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) in
            if let error = error,
                completion = completion {
                completion(record: nil, error: error)
            }
            if let record = recordID,
                completion = completion {
                //FetchRecordWithId
                self.fetchRecordWithId(recordID, completion: { (record, error) in
                    completion(record: record, error: error)
                })
            }
        }
    }
    func fetchRecordWithId(recordID: CKRecordID, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.fetchRecordWithID(recordID) { (record, error) in
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    }
}