//
//  TableViewCell.swift
//  Butikker
//
//  Created by Thomas Bjørk on 08/10/2015.
//  Copyright © 2015 Thomas Bjørk. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var titel: UILabel!
    @IBOutlet var budget: UILabel!
    @IBOutlet var omsætning: UILabel!
    @IBOutlet var antal: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
