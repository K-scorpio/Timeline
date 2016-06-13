//
//  SearchTableViewController.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/7/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchController: UISearchController?
    
    var posts: [Post]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posts = PostController.sharedInstance.posts
        setUpSearchController()
    }
    
    override func viewDidAppear(animated: Bool) {
        posts = PostController.sharedInstance.posts
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts?.count ?? 0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as? PostTableViewCell,
            let post = posts?[indexPath.row] else { return UITableViewCell() }
        
        cell.updateWithPost(post)
        
        return cell
    }
    
    // MARK: - Search Controller
    
    func setUpSearchController() {
        
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController?.searchBar
        
        definesPresentationContext = true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let resultsViewController = searchController.searchResultsController as? SearchResultsTableViewController,
            let searchTerm = searchController.searchBar.text?.lowercaseString,
            let posts = posts {
            
            resultsViewController.resultsArray = posts.filter({$0.matchesSearchTerm(searchTerm)})
            resultsViewController.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // segue from self
        
        if let detailViewController = segue.destinationViewController as? PostDetailTableViewController,
            let sender = sender as? PostTableViewCell,
            let selectedIndexPath = tableView.indexPathForCell(sender),
            let posts = posts {
            
            let post = posts[selectedIndexPath.row]
            
            detailViewController.post = post
        }
        
        // segue from search results
        
        if let detailViewController = segue.destinationViewController as? PostDetailTableViewController,
            let sender = sender as? PostTableViewCell,
            let selectedIndexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPathForCell(sender),
            let searchTerm = searchController?.searchBar.text?.lowercaseString,
            let posts = posts?.filter({ $0.matchesSearchTerm(searchTerm) }) {
            
            let post = posts[selectedIndexPath.row]
            
            detailViewController.post = post
        }
    }
}
