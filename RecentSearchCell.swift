//
//  RecentSearchCell.swift
//  UpgradedSleepingInTheLibrary
//
//  Created by Raj Balani on 29/07/19.
//  Copyright © 2019 balani. All rights reserved.
//

import UIKit

internal final class RecentSearchCell: UITableViewCell{
    @IBOutlet weak var nameLabel: UILabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
    }
}

