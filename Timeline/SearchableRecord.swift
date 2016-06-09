//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/9/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import Foundation

@objc protocol SearchableRecord: class {
    
    func matchesSearchTerm(searchTerm: String) -> Bool
    
}