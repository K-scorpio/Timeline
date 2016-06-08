//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Kevin Hartley on 6/7/16.
//  Copyright © 2016 Hartley Development. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    func updateWithPost(post: Post) {
        postImageView.image = post.photo
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
