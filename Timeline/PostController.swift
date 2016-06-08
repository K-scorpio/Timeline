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
    
    var fetchedResultsController: NSFetchedResultsController
    
    init() {
        let request = NSFetchRequest(entityName: "Post")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: "timestamp", cacheName: nil)
        _ = try? fetchedResultsController.performFetch()
    }
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Error saving to managed object context")
        }
    }
    
    func createPost(image: UIImage, caption: String, completion: (() -> Void)?) {
        if let image = UIImageJPEGRepresentation(image, 0.8) {
        let post = Post(photo: image, timestamp: NSDate(), caption: caption)
            print(post)
        }
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        let comment = Comment(post: post, text: text, timestamp: NSDate())
        print(comment)
        saveContext()
    }
}