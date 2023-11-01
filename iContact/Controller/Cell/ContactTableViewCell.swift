//
//  ContactTableViewCell.swift
//  iContact
//
//  Created by Айбану Уатбаева on 02.10.2023.
//

import UIKit

class ContactTableViewCell: UITableViewCell {


    
    @IBOutlet weak var contactTextLabel: UILabel!
    static let identifier: String = "ContactTableViewCellIdentifier"
    override func awakeFromNib() {
        super.awakeFromNib()
       // contactTextLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
