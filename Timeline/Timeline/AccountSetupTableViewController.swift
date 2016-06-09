//
//  AccountSetupTableViewController.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/8/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit

class AccountSetupTableViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func confirmButtonTapped(sender: AnyObject) {
        
        if let image = image, let text = displayNameTextField.text {
            
            UserController.sharedInstance.updateCurrentUser(text, profileImage: image)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            
            let alertController = UIAlertController(title: "Missing Profile", message: "Check your info.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "embedPhotoSelect" {
            
            let embedViewController = segue.destinationViewController as? PhotoSelectViewController
            embedViewController?.delegate = self
        }
    }
}

extension AccountSetupTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelected(image: UIImage) {
        
        self.image = image
    }
    
}
