//
//  OrderTableViewCell.swift
//  Services App
//
//  Created by Perov Alexey on 16.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

//MARK: - DELEGATE PROTOCOL
protocol OrderTableViewCellDelegate: class {
    func completeOrder(forCell cell: UITableViewCell)
}
//MARK: =

class OrderTableViewCell: UITableViewCell {

    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var serviceNameBackgroundView: UIView!
    @IBOutlet private weak var serviceNameLabel: UILabel!
    @IBOutlet private weak var providerPhotoImageView: UIImageView!
    @IBOutlet private weak var clientPhotoImageView: UIImageView!
    @IBOutlet private weak var providerNameLabel: UILabel!
    @IBOutlet private weak var clientNameLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var serviceCategoryLabel: UILabel!
    @IBOutlet weak var servicePriceLabel: UILabel!
    //MARK: -
    
    //MARK: - WAEK PUBLIC VARIABLES
    weak var delegate: OrderTableViewCellDelegate?
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureServiceNameBackground()
        configureProviderPhoto()
        configureClientPhoto()
        configureDoneButton()
    }
    //MARK: -

    //MARK: - OVERRIDDEN METHODS
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func configure(forOrder order: OrderModel) {
        serviceNameLabel.text = order.serviceName
        let service = try? ServiceEntity.find(serviceName: order.serviceName, serviceProviderID: order.providerID, stack: DataService.shared.sharedCoreStore)
        serviceCategoryLabel.text = service?.category?.name
        servicePriceLabel.text = "\(service?.pricePerHour ?? 0)$/h"
        if let image = order.providerPhoto {
            providerPhotoImageView.image = image
        } else {
            providerPhotoImageView.createImageWith(text: "\(String(order.providerName?.first ?? " "))", textSize: 30, textColor: .label, backgroundColor: .secondarySystemBackground)
        }
        providerNameLabel.text = order.providerName
        if let image = order.clientPhoto {
            clientPhotoImageView.image = image
        } else {
            clientPhotoImageView.createImageWith(text: "\(String(order.clientName?.first ?? " "))", textSize: 30, textColor: .label, backgroundColor: .secondarySystemBackground)
        }
        clientNameLabel.text = order.clientName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateLabel.text = dateFormatter.string(from: order.startDate)
    }
    
    func hideDoneButton() {
        doneButton.isHidden = true
    }
    
    func showDoneButton() {
        doneButton.isHidden = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.isUserInteractionEnabled = true
    }
    
    func showFinalPrice(price: Decimal) {
        doneButton.isHidden = false
        doneButton.setTitle("\(price)", for: .normal)
        doneButton.isUserInteractionEnabled = false
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureServiceNameBackground() {
        serviceNameBackgroundView.layer.cornerRadius = 10
        serviceNameBackgroundView.layer.masksToBounds = true
        serviceNameBackgroundView.layer.borderColor = UIColor.separator.cgColor
        serviceNameBackgroundView.layer.borderWidth = 2
    }
    
    private func configureProviderPhoto() {
        providerPhotoImageView.layer.cornerRadius = providerPhotoImageView.frame.height / 2
        providerPhotoImageView.layer.masksToBounds = true
        providerPhotoImageView.layer.borderColor = UIColor.separator.cgColor
        providerPhotoImageView.layer.borderWidth = 1
    }
    
    private func configureClientPhoto() {
        clientPhotoImageView.layer.cornerRadius = providerPhotoImageView.frame.height / 2
        clientPhotoImageView.layer.masksToBounds = true
        clientPhotoImageView.layer.borderColor = UIColor.separator.cgColor
        clientPhotoImageView.layer.borderWidth = 1
    }
    
    private func configureDoneButton() {
        doneButton.layer.cornerRadius = 8
        doneButton.layer.masksToBounds = true
    }
    //MARK: -
    
    //MARK: - PRIVATE IBACTIONS
    @IBAction private func completeButtonTapped(_ sender: UIButton) {
        delegate?.completeOrder(forCell: self)
    }

}
