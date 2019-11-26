//
//  ServiceTableViewCell.swift
//  Services App
//
//  Created by Perov Alexey on 16.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class ServiceTableViewCell: UITableViewCell {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var serviceNameBackgroundView: UIView!
    @IBOutlet private weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceCategoryLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureServiceNameBackground()
    }
    //MARK: -

    //MARK: - OVERRIDDEN METHODS
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func configure(forService service: ServiceModel) {
        serviceNameLabel.text = service.name
        serviceCategoryLabel.text = service.category?.name
        servicePriceLabel.text = "\(service.pricePerHour ?? 0)$"
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureServiceNameBackground() {
        serviceNameBackgroundView.layer.cornerRadius = 10
        serviceNameBackgroundView.layer.masksToBounds = true
    }
    //MARK: -
}
