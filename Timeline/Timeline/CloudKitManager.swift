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
    
    //MARK: - User Info Discovery
    
    func fetchLoggedInUserRecord(completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        CKContainer.defaultContainer().fetchUserRecordIDWithCompletionHandler { (recordID, error) in
            if let error = error,
                completion = completion {
                completion(record: nil, error: error)
            }
            if let recordID = recordID,
                completion = completion {
                //FetchRecordWithId
                self.fetchRecordWithId(recordID, completion: { (record, error) in
                    completion(record: record, error: error)
                })
            }
        }
    }
    
    func fetchUsernameFromRecordID(recordID: CKRecordID, completion: ((firstName: String?, lastName: String?) -> Void)?) {
        let operation = CKDiscoverUserInfosOperation(emailAddresses: nil, userRecordIDs: [recordID])
        operation.discoverUserInfosCompletionBlock = { (emailsToUserInfos, userRecordIDsToUserInfos, error) -> Void in
            if let userRecordIDsToUserInfos = userRecordIDsToUserInfos,
                let userInfo = userRecordIDsToUserInfos[recordID],
                let completion = completion {
                completion(firstName: userInfo.displayContact?.givenName, lastName: userInfo.displayContact?.familyName)
            } else if let completion = completion {
                completion(firstName: nil, lastName: nil)
            }
        }
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    func fetchAllDiscoverableUsers(completion: ((userInfoRecords: [CKDiscoveredUserInfo]?) -> Void)?) {
        let operation = CKDiscoverAllContactsOperation()
        
        operation.discoverAllContactsCompletionBlock = { (discoverUserInfos, error) -> Void in
            if let completion = completion {
                completion(userInfoRecords: discoverUserInfos)
            }
        }
        CKContainer.defaultContainer().addOperation(operation)
    }
    
    //MARK: - Fetch Record
    
    func fetchRecordWithId(recordID: CKRecordID, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.fetchRecordWithID(recordID) { (record, error) in
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    }
    
    func fetchRecordsWithType(type: String, predicate: NSPredicate = NSPredicate(value: true), recordFetchedBlock: ((record: CKRecord) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        var fetchedRecords: [CKRecord] = []
        
        let predicate = predicate
        let query = CKQuery(recordType: type, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        queryOperation.recordFetchedBlock = { (fetchedRecord) -> Void in
            fetchedRecords.append(fetchedRecord)
            
            if let recordFetchedBlock = recordFetchedBlock {
                recordFetchedBlock(record: fetchedRecord)
            }
        }
        
        queryOperation.queryCompletionBlock = { (queryCursor, error) -> Void in
            if let queryCursor = queryCursor {
                // There are more results, go fetch(query) them
                let continuedQueryOperation = CKQueryOperation(cursor: queryCursor)
                continuedQueryOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                continuedQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                
                self.publicDatabase.addOperation(continuedQueryOperation)
            } else {
                if let completion = completion {
                    completion(records: fetchedRecords, error: error)
                }
            }
        }
        self.publicDatabase.addOperation(queryOperation)
    }
    
    func fetchCurrentUserRecords(type: String, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        fetchLoggedInUserRecord { (record, error) in
            if let record = record {
                let predicate = NSPredicate(format: "%K == %@", argumentArray: ["creatorUserRecordID", record.recordID])
                
                self.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: nil, completion: { (records, error) in
                    if let completion = completion {
                        completion(records: records, error: error)
                    }
                })
            }
        }
    }
    
    //MARK: - Delete
    
    func deleteRecordWithId(recordID: CKRecordID, completion: ((recordID: CKRecordID?, error: NSError?) -> Void)?) {
        //delete record from public database
        publicDatabase.deleteRecordWithID(recordID) { (recordID, error) in
            if let completion = completion {
                completion(recordID: recordID, error: error)
            }
        }
    }
    
    func deleteRecordsWithID(recordIDs: [CKRecordID], completion: ((records: [CKRecord]?, recordIDs: [CKRecordID]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
        operation.savePolicy = .IfServerRecordUnchanged
        operation.queuePriority = .High
        operation.qualityOfService = .UserInitiated
        
        operation.modifyRecordsCompletionBlock = { (records, recordIDs, error) -> Void in
            if let completion = completion {
                completion(records: records, recordIDs: recordIDs, error: error)
            }
        }
    }
    
    //MARK: - Save and Modify
    
    func saveRecord(record: CKRecord, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
        publicDatabase.saveRecord(record) { (record, error) in
            if let completion = completion {
                completion(record: record, error: error)
            }
        }
    }
    
    func saveRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        
        modifyRecords(records, perRecordCompletion: perRecordCompletion) { (records, error) in
            
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
    }
    
    func modifyRecords(records: [CKRecord], perRecordCompletion: ((record: CKRecord?, error: NSError?) -> Void)?, completion: ((records: [CKRecord]?, error: NSError?) -> Void)?) {
        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.savePolicy = .ChangedKeys
        operation.queuePriority = .High
        operation.qualityOfService = .UserInteractive
        
        operation.perRecordCompletionBlock = { (record, error) -> Void in
            if let perRecordCompletion = perRecordCompletion {
                perRecordCompletion(record: record, error: error)
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (records, recordIds, error) -> Void in
            if let completion = completion {
                completion(records: records, error: error)
            }
        }
        publicDatabase.addOperation(operation)
    }
    
    //MARK: - CloudKit Permissions
    
    func checkCloudKitAvailability() {
        CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus: CKAccountStatus, error) in
            switch accountStatus {
            case .Available:
                return
            default:
                //Call other method
                self.handleCloudKitUnavailable(accountStatus, error: error)
            }
        }
    }
    
    func handleCloudKitUnavailable(accountStatus: CKAccountStatus, error: NSError?) {
        
        var errorText = "Synchronization is disabled"
        
        if let error = error {
            print("An error occured: \(error.localizedDescription)")
        }
        
        switch accountStatus {
        case .Restricted:
            errorText += "iCloud is restricted"
        case .NoAccount:
            errorText += "No account setup for iCloud"
        default:
            break
        }
        displayCloudKitNotAvailableError(errorText)
    }
    
    func displayCloudKitNotAvailableError(errorText: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "Error Occurred", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - CloudKit Discoverability
    
    func requestDiscoverabilityPermission() {
        CKContainer.defaultContainer().statusForApplicationPermission(.UserDiscoverability) { (permissionStatus, error) in
            if permissionStatus == .InitialState {
                CKContainer.defaultContainer().requestApplicationPermission(.UserDiscoverability, completionHandler: { (permissionStatus, error) in
                    //Call Other Method
                    self.handleCloudKitPermissionStatus(permissionStatus, error: error)
                })
            } else {
                // Call Other Method
                self.handleCloudKitPermissionStatus(permissionStatus, error: error)
            }
        }
    }
    
    func displayCloudKitPermissionsGrantedError(errorText: String) {
        dispatch_async(dispatch_get_main_queue()) {
            let alertController = UIAlertController(title: "CloudKit Permissions Error", message: errorText, preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            
            if let appDelegate = UIApplication.sharedApplication().delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func handleCloudKitPermissionStatus(permissionStatus: CKApplicationPermissionStatus, error: NSError?) {
        var errorText = "Sync is disabled \n"
        if permissionStatus == .Granted {
            print("You have full access! YIPPEE!!!!!")
        } else {
            if let error = error {
                print("An error occurred \(error.localizedDescription)")
                errorText += error.localizedDescription
            }
        }
        
        switch permissionStatus {
        case .Denied:
            errorText += "You denied me... How rude..."
        case .CouldNotComplete:
            errorText += "Unable to verify User Discoverability permissions. You may have a connectivity issue. Please try again."
        default:
            break
        }
    }
}














