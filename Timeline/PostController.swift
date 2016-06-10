//
//  PostController.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit
import CoreData

class PostController {
    
    static let sharedInstance = PostController()
    
    let cloudKitManager: CloudKitManager
    
    var posts: [Post] {
        let request = NSFetchRequest(entityName: "Post")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(request)) as? [Post] ?? []
        return results
    }
    
    init() {
        self.cloudKitManager = CloudKitManager()
    }
    
    func createPost(image: UIImage, caption: String, completion: (() -> Void)?) {
        guard let image = UIImageJPEGRepresentation(image, 0.8) else { return }
        let post = Post(photo: image)
        
        // add comment to post
        saveContext()
        
        addCommentToPost(caption, post: post, completion: nil)
        
        if let completion = completion {
            completion()
        }
        
        if let postRecord = post.cloudKitRecord {
            cloudKitManager.saveRecord(postRecord, completion: { (record, error) in
                if let record = record {
                    post.update(record)
                }
            })
        }
    }
    
    func addCommentToPost(text: String, post: Post, completion: ((success: Bool) -> Void)?) {
        let comment = Comment(post: post, text: text)
        saveContext()
        if let completion = completion {
            completion(success: true)
        }
        if let commentRecord = comment.cloudKitRecord {
            cloudKitManager.saveRecord(commentRecord, completion: { (record, error) in
                if let record = record {
                    comment.update(record)
                }
            })
        }
    }
    
    func postWithName(name: String) -> Post? {
        if name.isEmpty { return nil }
        let fetchRequest = NSFetchRequest(entityName: "Post")
        let predicate = NSPredicate(format: "recordName != nil", argumentArray: [name])
        fetchRequest.predicate = predicate
        
        let result = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Post] ?? nil)
        
        return result??.first
    }
    
    //MARK: - Sync
    
    func fullSync() {
        pushChangesToCloudKit { (success, error) in
            self.fetchNewRecords("Post", completion: { 
                self.fetchNewRecords("comment", completion: nil)
            })
        }
    }
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData != nil")
        fetchRequest.predicate = predicate
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        
        return results
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: type)
        let predicate = NSPredicate(format: "recordIDData == nil")
        fetchRequest.predicate = predicate
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        
        return results
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)?) {
        let referencesToExclude = syncedRecords(type).flatMap({$0.cloudKitReference})
        var predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        if referencesToExclude.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            switch type {
            case "Post":
                let _ = Post(record: record)
            case "Comment":
                let _ = Comment(record: record)
            default:
                return
            }
            self.saveContext()
        }) { (records, error) in
            if error != nil {
                print("😈")
            }
            if let completion = completion {
                completion()
            }
        }
    }
    
    func pushChangesToCloudKit(completion: ((success: Bool, error: NSError?) -> Void)?) {
        let unsavedManagedObjects = unsyncedRecords("Post") + unsyncedRecords("Comment")
        let unsavedRecords = unsavedManagedObjects.flatMap({$0.cloudKitRecord})
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            guard let record = record else { return }
            if let matchingRecord = unsavedManagedObjects.filter({$0.recordName == record.recordID.recordName}).first {
                matchingRecord.update(record)
            }
        }) { (records, error) in
            if let completion = completion {
            let success = records != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error saving to managed object context")
        }
    }
}