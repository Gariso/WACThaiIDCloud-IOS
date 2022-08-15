//
//  ItemDataCell.swift
//  WACThaiIDCloud
//
//  Created by Thananchai Pinyo on 4/8/2565 BE.
//

import UIKit

class ItemDataCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = "-"
        valueLabel.text = "-"
    }

    func configureCell(title: String, value: String) {
        titleLabel.text = title
        if value.isEmpty || value == "  " || value == "        " {
            valueLabel.text = "-"
        } else {
            valueLabel.text = value
        }
    }
    
}
