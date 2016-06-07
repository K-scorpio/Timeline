//
//  User.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/6/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit

struct User {
    
    private let displayNameKey = "displayName"
    private let profileImageURLKey = "profileImageURL"
    
    var displayName: String
    var profileImageURL: String
    
    init?(displayName: String, profileImageURL: String) {
        self.displayName = displayName
        self.profileImageURL = profileImageURL
    }
    
    var profileImage: UIImage? {
        guard let profileImageData = NSData(contentsOfFile: profileImageURL) else {
            return nil
        }
        return UIImage(data: profileImageData)
    }
    
    var dictionaryValue: [String: AnyObject] {
        let userDictionary = [displayNameKey: displayName, profileImageURLKey: profileImageURL]
        return userDictionary
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let displayName = dictionary[displayNameKey] as? String,
            profileImageURL = dictionary[profileImageURLKey] as? String else {
                return nil
        }
        self.displayName = displayName
        self.profileImageURL = profileImageURL
    }
}