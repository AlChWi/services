//
//  AllServicesViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class AllServicesViewController: UIViewController, Instantiatable {
    
    //MARK: - PRIVATE IBACTIONS
    @IBOutlet private weak var servicesTableView: UITableView! {
        didSet {
            servicesTableView.delegate = self
            servicesTableView.dataSource = self
            let nib = UINib(nibName: Constants.NibNames.serviceWithProviderCell, bundle: nil)
            servicesTableView.register(nib, forCellReuseIdentifier: Constants.CellIDs.serviceCell)
            servicesTableView.addSubview(refreshControl)
            servicesTableView.tableFooterView = UIView()
        }
    }
    //MARK: -
    
    //MARK: - PRIVATE LAZY VARIABLES
    private lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    private var refreshControl = UIRefreshControl()
    private var coordinator: MainCoordinator?
    private var services: [ServiceModel] = [] {
        didSet {
            servicesTableView.reloadData()
            providers = services.compactMap { ProviderModel(fromEntity: DataService.shared.findUser(byID: $0.providerID) as? ProviderEntity) }
        }
    }
    private var providers: [ProviderModel] = []
    private var filteredProviders: [ProviderModel] = []
    private var notificationGenerator = UINotificationFeedbackGenerator()
    private var selectionGenerator = UISelectionFeedbackGenerator()
    var filteredServices: [ServiceModel] = [] {
        didSet {
            servicesTableView.reloadData()
            filteredProviders = filteredServices.compactMap { ProviderModel(fromEntity: DataService.shared.findUser(byID: $0.providerID) as? ProviderEntity) }
        }
    }
    var isSearchBarEmpty: Bool {
        searchBarController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchBarController.isActive && !isSearchBarEmpty
    }
    
    private lazy var searchBarController = UISearchController(searchResultsController: nil)
    //MARK: -
    
    //MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchBarController
        searchBarController.searchResultsUpdater = self
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.searchBar.placeholder = "service name"
        
        configureNavigationItem()
        configureRefreshAndPrepareInfo()
    }
    //MARK: -
    
    //MARK: - PUBLIC METHODS
    func setCoordinator(_ coordinator: MainCoordinator?) {
        self.coordinator = coordinator
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    private func configureRefreshAndPrepareInfo() {
        refreshControl.addTarget(self, action: #selector(refreshInfo), for: .valueChanged)
        refreshControl.programaticallyBeginRefreshing(in: servicesTableView)
    }
    
    @objc private func refreshInfo() {
        DispatchQueue.global(qos: .userInitiated).async {
            let servicesToAdd = DataService.shared.findServices()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                self.services = servicesToAdd.sorted { $0.name.lowercased() < $1.name.lowercased() }
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func configureNavigationItem() {
        title = "All Services"
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    //MARK: -
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension AllServicesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredServices.count
        } else {
            return services.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = servicesTableView.dequeueReusableCell(withIdentifier: Constants.CellIDs.serviceCell, for: indexPath) as? ServiceWithProviderTableViewCell
        if isFiltering {
            cell?.configure(forService: filteredServices[indexPath.row], andProvider: filteredProviders[indexPath.row])
        } else {
            cell?.configure(forService: services[indexPath.row], andProvider: providers[indexPath.row])
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionGenerator.selectionChanged()
        if isFiltering {
            coordinator?.chooseDate(forService: filteredServices[indexPath.row], fromScreen: self)
        } else {
            coordinator?.chooseDate(forService: services[indexPath.row], fromScreen: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
//MARK: -

extension AllServicesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredServices = services.filter({ (service) -> Bool in
            return service.name.lowercased().contains(searchText.lowercased()) || service.category?.name.lowercased().contains(searchText.lowercased()) ?? false
        })
        
        servicesTableView.reloadData()
    }
}
