//
//  MyServicesViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class MyServicesViewController: UIViewController, Instantiatable {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var myServicesTableView: UITableView! {
        didSet {
            myServicesTableView.delegate = self
            myServicesTableView.dataSource = self
            let nib = UINib(nibName: Constants.NibNames.serviceCell, bundle: nil)
            myServicesTableView.register(nib, forCellReuseIdentifier: Constants.CellIDs.serviceCell)
            myServicesTableView.tableFooterView = UIView()
            myServicesTableView.addSubview(refreshControl)
        }
    }
    //MARK: -
    
    //MARK: - PRIVATE LAZY VARIABLES
    private lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var coordinator: MainCoordinator?
    private var services: [ServiceModel] = []
    private var refreshControl = UIRefreshControl()
    //MARK: -
        
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        configureRefreshAndPrepareInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(handleServiceCreated(_:)), name: .serviceCreated, object: nil)
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func setCoordinator(_ coordinator: MainCoordinator?) {
        self.coordinator = coordinator
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    @objc private func handleServiceCreated(_ notification: Notification) {
        if let userInfo = notification.userInfo, let service = userInfo[Constants.UserInfoKeys.service] as? ServiceModel {
            services.append(service)
            services.sort(by: { $0.name < $1.name } )
            myServicesTableView.reloadData()
        }
    }
    
    private func configureRefreshAndPrepareInfo() {
        refreshControl.addTarget(self, action: #selector(refreshServices), for: .valueChanged)
        refreshControl.programaticallyBeginRefreshing(in: myServicesTableView)
    }
    
    private func configureNavigationItem() {
        title = "I Offer"
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc private func addButtonTapped() {
        coordinator?.addService(fromScreen: self)
    }
    
    @objc private func refreshServices() {
        guard let provider = coordinator?.currentUser as? ProviderModel else {
            return
        }
        let services = DataService.shared.findServicesFor(provider: provider)
        let sortedServices = services.sorted { $0.name.lowercased() < $1.name.lowercased() }
        self.services = sortedServices
        myServicesTableView.reloadData()
        
        refreshControl.endRefreshing()
    }
    //MARK: -
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MyServicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myServicesTableView.dequeueReusableCell(withIdentifier: Constants.CellIDs.serviceCell, for: indexPath) as? ServiceTableViewCell
        cell?.configure(forService: services[indexPath.row])
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? DataService.shared.delete(service: services[indexPath.row])
            services.remove(at: indexPath.row)
            myServicesTableView.beginUpdates()
            myServicesTableView.deleteRows(at: [indexPath], with: .automatic)
            myServicesTableView.endUpdates()
        }
    }
}
//MARK: -
