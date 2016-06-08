//
//  UserController.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/7/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit
import CoreData

class UserController {

    static let sharedInstance = UserController()
    
    var currentUser: User?
    private let kUserData = "userData"
    
    init?() {
        guard let userDictionary = NSUserDefaults.standardUserDefaults().objectForKey(kUserData) as? [String: AnyObject] else {
            return nil
        }
        if let cUSER = User(dictionary: userDictionary) {
        currentUser = cUSER
        }
    }
    
    func updateCurrentUser(displayName: String, profileImage: UIImage) {
        
        guard let imageData = UIImageJPEGRepresentation(profileImage, 0.8) else {
            return
        }
        
        let filePath = getDocumentsDirectory().stringByAppendingPathComponent("profileImage.jpg")
        imageData.writeToFile(filePath, atomically: true)
        
        currentUser = User(displayName: displayName, profileImageURL: filePath)
    }
    
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
