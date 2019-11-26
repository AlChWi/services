//
//  ServiceWithProviderTableViewCell.swift
//  Services App
//
//  Created by Perov Alexey on 17.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class ServiceWithProviderTableViewCell: UITableViewCell {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var serviceNameBackgroundView: UIView!
    @IBOutlet private weak var serviceNameLabel: UILabel!
    @IBOutlet private weak var providerNameLabel: UILabel!
    @IBOutlet private weak var providerPhotoImageView: UIImageView!
    @IBOutlet weak var serviceCategoryLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    //MARL: -
    
    //MARK: - LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        configureProviderPhoto()
        configureServiceNameBackground()
    }
    //MARK: -

    //MARK: - OVERRIDDEN METHODS
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func configure(forService service: ServiceModel, andProvider provider: ProviderModel) {
        self.serviceNameLabel.text = service.name
        self.providerNameLabel.text = "\(provider.firstName) \(provider.lastName)"
        self.serviceCategoryLabel.text = service.category?.name
        self.servicePriceLabel.text = "\(service.pricePerHour ?? 0)$/h"
        if let image = provider.image {
            self.providerPhotoImageView.image = image
        } else {
            providerPhotoImageView.createImageWith(text: "\(String(provider.firstName.first ?? " "))\(String(provider.lastName.first ?? " "))", textSize: 30, textColor: .label, backgroundColor: .secondarySystemBackground)
        }
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureProviderPhoto() {
        providerPhotoImageView.layer.cornerRadius = providerPhotoImageView.frame.width / 2
        providerPhotoImageView.layer.masksToBounds = true
        providerPhotoImageView.layer.borderWidth = 1
        providerPhotoImageView.layer.borderColor = UIColor.black.cgColor
        providerPhotoImageView.backgroundColor = .secondarySystemBackground
    }
    
    private func configureServiceNameBackground() {
        serviceNameBackgroundView.layer.cornerRadius = 8
        serviceNameBackgroundView.layer.masksToBounds = true
    }
    //MARK: -
}
