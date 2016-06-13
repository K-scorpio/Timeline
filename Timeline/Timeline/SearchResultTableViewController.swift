//
//  SearchResultTableViewController.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/7/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    var resultsArray = [SearchableRecord]()
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as? PostTableViewCell,
            let result = resultsArray[indexPath.row] as? Post else { return UITableViewCell() }
        
        cell.updateWithPost(result)
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.presentingViewController?.performSegueWithIdentifier("toPostDetail", sender: cell)
    }
}