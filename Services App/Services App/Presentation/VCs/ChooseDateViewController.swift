//
//  ChooseDateViewController.swift
//  Services App
//
//  Created by Perov Alexey on 17.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class ChooseDateViewController: UIViewController, Instantiatable {
    
    //MARK: PRIVATE IBOUTLETS
    @IBOutlet private weak var backgroundVisualEffectView: UIVisualEffectView!
    @IBOutlet private weak var backgroundContentView: UIView!
    @IBOutlet private weak var orderDatePicker: UIDatePicker! {
        didSet {
            orderDatePicker.datePickerMode = .dateAndTime
            orderDatePicker.minimumDate = Date(timeIntervalSinceNow: 3600)
        }
    }
    @IBOutlet private weak var instructionLabel: UILabel!
    @IBOutlet weak var noteTextLabel: UILabel!
    @IBOutlet private weak var placeOrderButton: UIButton!
    @IBOutlet private weak var cancelOrderButton: UIButton!
    @IBOutlet private weak var tapView: UIView!
    //MARK: -
    
    //MARK: - PRIVATE LAZY VARIABLES
    private lazy var backgroundTap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var service: ServiceModel?
    private var client: ClientModel?
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        noteTextLabel.text! += "\n This service usually takes \(service?.category?.standardLength ?? 0) hours"

        noteTextLabel.numberOfLines = 0
        configureVisualEffectBackground()
        configureDismissingTap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startShadowAppearAnimation()
        
        orderDatePicker.date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date(timeIntervalSinceNow: 86400)) ?? Date()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        startShadowDisappearAnimation()
    }
    //MARK: -
    
    //MARK: PUBLIC METHODS
    func configure(forService service: ServiceModel, andClient client: ClientModel) {
        self.client = client
        self.service = service
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureVisualEffectBackground() {
        backgroundVisualEffectView.layer.cornerRadius = 10
        backgroundVisualEffectView.layer.masksToBounds = true
    }
    
    private func configureDismissingTap() {
        self.tapView.addGestureRecognizer(backgroundTap)
    }
    
    private func startShadowAppearAnimation() {
        let shadowAppearAnimation = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) { [weak self] in
            guard let self = self else {
                return
            }
            self.view.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        }
        shadowAppearAnimation.startAnimation()
    }
    
    private func startShadowDisappearAnimation() {
        let shadowDisappearAnimation = UIViewPropertyAnimator(duration: 0.02, curve: .easeIn) { [weak self] in
            guard let self = self else {
                return
            }
            self.view.backgroundColor = .clear
        }
        shadowDisappearAnimation.startAnimation()
    }
    
    @objc private func handleBackgroundTap() {
        dismiss(animated: true, completion: nil)
    }
    
    private func shake() {
        let midX = backgroundVisualEffectView.center.x
        let midY = backgroundVisualEffectView.center.y
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = backgroundVisualEffectView.center
        animation.toValue = CGPoint(x: midX + 10, y: midY + 1)
        backgroundVisualEffectView.layer.add(animation, forKey: "position")
    }
    //MARK: -
    
    //MARK: - PRIVATE IBACTIONS
    @IBAction private func orderButtonTapped(_ sender: UIButton) {
        guard let clientID = client?.id, let providerID = service?.providerID, let serviceName = service?.name else {
            return
        }
        let order = OrderModel(date: orderDatePicker.date, clientID: clientID, providerID: providerID, serviceName: serviceName)
        
        //CAN'T CREATE ORDER IF PROVIDER HAS ANOTHER ORDERS WITHIN AN HOUR
        if let id = service?.providerID,
            let otherOrders = try? DataService.shared.findOrders(forUserByID: id, date: orderDatePicker.date),
            !otherOrders.isEmpty {
            let alert = UIAlertController(title: "Date",
                                          message: "This provider has another order with time that intersects with this order. Please, choose another time",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) in
                alert?.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            shake()
            
            return
        }
        
        let orderEntity = try? DataService.shared.create(order: order)
        order.clientName = "\(orderEntity?.client?.firstName ?? " ") \(orderEntity?.client?.lastName ?? " ")"
        if let photo = orderEntity?.client?.image {
            order.clientPhoto = UIImage(data: photo)
        }
        order.providerName = "\(orderEntity?.service?.toProvider?.firstName ?? " ") \(orderEntity?.service?.toProvider?.lastName ?? " ")"
        if let photo = orderEntity?.service?.toProvider?.image {
            order.providerPhoto = UIImage(data: photo)
        }
        
        
        let userInfo = ["Order" : order]
        NotificationCenter.default.post(name: .orderCreated, object: nil, userInfo: userInfo)
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func datePickerValueChanged(_ sender: UIDatePicker) {
        let chosenDate = sender.date
        let hour = Calendar.current.component(.hour, from: chosenDate)
        if hour >= 20 {
            sender.date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: sender.date) ?? Date()
        }
        if hour < 8 {
            sender.date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: sender.date) ?? Date()
        }
    }
    //MARK: -
}
