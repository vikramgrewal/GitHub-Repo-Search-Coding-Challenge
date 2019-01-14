//
//  RepoCollectionViewCell.swift
//  GitHubSearchDemo
//
//  Created by Vikram Grewal on 1/13/19.
//  Copyright © 2019 Vikram Grewal. All rights reserved.
//

import UIKit

class RepoCollectionViewCell: UICollectionViewCell {
    
    var nameLabel : UILabel!
    var descriptionLabel : UILabel!
    var dateLabel : UILabel!
    var licenseLabel : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func willTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        layoutIfNeeded()
    }
    
    
    
    func setupView()    {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: CGFloat(15.0))
        contentView.addSubview(nameLabel)
        
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: CGFloat(13.0))
        contentView.addSubview(descriptionLabel)
        
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont(name: "AvenirNextCondensed-UltraLight", size: CGFloat(13.0))
        contentView.addSubview(dateLabel)

        licenseLabel = UILabel()
        licenseLabel.translatesAutoresizingMaskIntoConstraints = false
        licenseLabel.font = UIFont(name: "AvenirNextCondensed-UltraLight", size: CGFloat(13.0))
        contentView.addSubview(licenseLabel)
        
        setConstraints()
    }
    
    func setConstraints()   {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),

            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            licenseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            licenseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            licenseLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor)
        ])
    }
    
}
