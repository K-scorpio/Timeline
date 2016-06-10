//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    
    let postController = PostController()
    
    var post: Post?
    
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let post = post {
            
            updateWithPost(post)
        }
        
        setUpFetchedResultsController()
        
    }
    
    func updateWithPost(post: Post) {
        
        myImageView.image = post.photo
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 1 }
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        if let comment = fetchedResultsController?.objectAtIndexPath(indexPath) as? Comment {
            
            cell.textLabel?.text = comment.text
            cell.detailTextLabel?.text = comment.text
        }
        
        return cell
    }
    
    func setUpFetchedResultsController() {
        
        guard let post = post else { fatalError("Unable to use Post to set up fetched results controller.") }
        
        let request = NSFetchRequest(entityName: "Comment")
        let predicate = NSPredicate(format: "post == %@", argumentArray: [post])
        let dateSortDescription = NSSortDescriptor(key: "timestamp", ascending: true)
        
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        request.sortDescriptors = [dateSortDescription]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch request: \(error.localizedDescription)")
        }
        
        fetchedResultsController?.delegate = self
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case .Move:
            guard let indexPath = indexPath,
                newIndexPath = newIndexPath else {return}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case .Update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    @IBAction func followUserButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        presentCommentAlert()
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        presentActivityViewController()
    }
    
    func presentCommentAlert() {
        
        let alertController = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            
            textField.placeholder = "Nice shot!"
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .Default) { (action) in
            
            guard let commentText = alertController.textFields?.first?.text,
                let post = self.post else { return }
            
            PostController.sharedInstance.addCommentToPost(commentText, post: post, completion: nil)
        }
        alertController.addAction(addCommentAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentActivityViewController() {
        
        let photo = post?.photo
        guard let comment = post?.comments.firstObject as? Comment  else {
            return
        }
        let text = comment.text
        
        let activityViewController = UIActivityViewController(activityItems: [photo!, text], applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}
