//
//  ImagesTableViewCell.swift
//  MindValley
//
//  Created by Kelvin Tan on 7/25/18.
//  Copyright © 2018 Kelvin Tan. All rights reserved.
//

import UIKit
import Kingfisher

class ImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var listImages: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(data: Image){
        let url = URL(string: data.imageLink)
        imageView?.kf.setImage(with: url)
    }

}
