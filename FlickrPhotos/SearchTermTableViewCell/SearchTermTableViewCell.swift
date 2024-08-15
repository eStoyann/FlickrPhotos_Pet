//
//  SearchTermTableViewCell.swift
//  FlickrPhotos
//
//  Created by Evgeniy Stoyan on 18.07.2024.
//

import UIKit

class SearchTermTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var searchTermLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        searchTermLabel.text = nil
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        separatorInset = .zero
    }
    
    func set(searchText: String?) {
        searchTermLabel.text = searchText
    }
}
