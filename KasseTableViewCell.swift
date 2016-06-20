//
//  KasseTableViewCell.swift
//  POS-Tool
//
//  Created by Thomas Bjørk on 20/06/2016.
//  Copyright © 2016 Thomas Bjørk. All rights reserved.
//

import UIKit

class KasseTableViewCell: UITableViewCell {

    @IBOutlet var omsaetning: UILabel!
    @IBOutlet var navn: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
