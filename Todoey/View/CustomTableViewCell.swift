//
//  CustomTableViewCell.swift
//  Todoey
//
//  Created by Gustavo Dias on 27/12/22.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    static let identifier = "CustomTableViewCell"
    var content: String!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var contentConfig = defaultContentConfiguration().updated(for: state)
        contentConfig.text = content
        
        contentConfiguration = contentConfig
    }
}
