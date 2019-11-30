//
//  OrdersSegmentedViewController.swift
//  Services App
//
//  Created by Алексей Перов on 28.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit
import SnapKit

class OrdersSegmentedViewController: UIViewController {
    
    var notCompletedOrdersVC = OrderedServicesViewController.instantiate()
    var completedOrdersVC = OrderedServicesViewController.instantiate()
    var coordinator: AppCoordinator?
    var segmentedControl = UISegmentedControl(items: ["Completed", "Pending"])
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = segmentedControl

        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        addChild(notCompletedOrdersVC)
        view.addSubview(notCompletedOrdersVC.view)
        addChild(completedOrdersVC)
        view.addSubview(completedOrdersVC.view)
    }
    @objc
    func didChangeSegment() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            notCompletedOrdersVC.view.isHidden = true
            completedOrdersVC.view.isHidden = false
        case 1:
            notCompletedOrdersVC.view.isHidden = false
            completedOrdersVC.view.isHidden = true
        default:
            break
        }
    }
}
