//
//  tripCell.swift
//  
//
//  Created by Apple on 30/01/17.
//
//

import UIKit
import MapKit

class tripCell: UITableViewCell {


    @IBOutlet weak var tMapView: MKMapView!
    @IBOutlet weak var tStartAdd: UILabel!
    @IBOutlet weak var tEndAdd: UILabel!
    @IBOutlet weak var tDate: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
     
        
        // Configure the view for the selected state
    }

}
