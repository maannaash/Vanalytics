//
//  carCell.swift
//  Vanalytics
//
//  Created by Apple on 19/01/17.
//  Copyright © 2017 maannaash. All rights reserved.
//

import UIKit

class carCell: UITableViewCell {

    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
