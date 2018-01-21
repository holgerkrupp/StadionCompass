//
//  StadiumSelectorCell.swift
//  StadionCompass
//
//  Created by Holger Krupp on 21.01.18.
//  Copyright © 2018 Holger Krupp. All rights reserved.
//

import UIKit

class StadiumSelectorCell: UITableViewCell {

    @IBOutlet weak var TeamNameLabel: UILabel!
    @IBOutlet weak var IconLabel: UILabel!
    @IBOutlet weak var StadiumNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
