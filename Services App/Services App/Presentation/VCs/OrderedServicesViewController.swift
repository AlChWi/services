//
//  OrderedServicesViewController.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit

class OrderedServicesViewController: UIViewController, Instantiatable {
    
    //MARK: - PRIVATE IBOUTLETS
    @IBOutlet private weak var ordersTableView: UITableView! {
        didSet {
            ordersTableView.delegate = self
            ordersTableView.dataSource = self
            let nib = UINib(nibName: Constants.NibNames.orderCell, bundle: nil)
            ordersTableView.register(nib, forCellReuseIdentifier: Constants.CellIDs.orderCell)
            ordersTableView.addSubview(refreshControl)
        }
    }
    //MARK: -
    
    //MARK: - PRIVATE VARIABLES
    //MARK: - CONSTANTS
    private let refreshControl = UIRefreshControl()
    //MARK: -
    
    //MARK: - LAZY
    private lazy var addOrderButton = showingContentFor == .provider ? nil : UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    //MARK: -
    
    //MARK: - WEAK
    private weak var coordinator: MainCoordinator?
    //MARK: -
    
    private var ordersForDate: [OrdersForDate] = []
    private var showingContentFor: Role?
    
    var filteredOrders: [OrderModel] = [] {
        didSet {
            ordersTableView.reloadData()
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
        searchBarController.searchBar.placeholder = "Service name/category/provider/client"
        definesPresentationContext = true

        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewOrder(_:)), name: .orderCreated, object: nil)
        configureNavigationItem()
        configureRefreshAndPrepareInfo()
    }
    //MARK: -
        
    //MARK: - PUBLIC METHODS
    func configureFor(role: Role) {
        self.showingContentFor = role
    }
    
    func setCoordinator(_ coordinator: MainCoordinator?) {
        self.coordinator = coordinator
    }
    //MARK: -
    
    //MARK: - PRIVATE METHODS
    @objc private func handleNewOrder(_ notification: Notification) {
        let userInfo = notification.userInfo
        if let order = userInfo?[Constants.UserInfoKeys.order] as? OrderModel {
            hasAnotherOrdersWithinDay: if let ordersStructure = ordersForDate.first(where: { Calendar.current.compare($0.date, to: order.startDate, toGranularity: .day) == .orderedSame } ) {
                ordersStructure.orders?.append(order)
                ordersStructure.orders?.sort(by: { $0.startDate > $1.startDate })
                if let rowIndex = ordersStructure.orders?.firstIndex(where: { $0 === order } ), let sectionIndex = ordersForDate.firstIndex(where: { $0 === ordersStructure } ) {
                    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                    ordersTableView.insertRows(at: [indexPath], with: .none)
                }
//                ordersTableView.reloadData()
            } else {
                let ordersStructure = OrdersForDate(date: order.startDate, orders: [order])
                ordersForDate.append(ordersStructure)
                ordersForDate.sort(by: { $0.date > $1.date })
                if let sectionIndex = ordersForDate.firstIndex(where: { $0 === ordersStructure } ) {
                    let indexSet = IndexSet(integer: sectionIndex)
                    ordersTableView.insertSections(indexSet, with: .none)
                }
//                ordersTableView.reloadData()
            }
        }
        
    }
    
    private func configureRefreshAndPrepareInfo() {
        refreshControl.addTarget(self, action: #selector(refreshOrders), for: .valueChanged)
        refreshControl.programaticallyBeginRefreshing(in: ordersTableView)
    }
    
    private func configureNavigationItem() {
        title = "Orders"
        navigationItem.rightBarButtonItem = addOrderButton
    }
    
    @objc private func refreshOrders() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let user = self?.coordinator?.currentUser {
                let orders = try? DataService.shared.findOrders(forUser: user)
                guard let definatelyOrders = orders else {
                    return
                }
                self?.ordersForDate = []
                organizeOrdersByDays: for order in definatelyOrders {
                    hasAnotherOrdersWithinDay: if let ordersStructure = self?.ordersForDate.first(where: { Calendar.current.compare($0.date, to: order.startDate, toGranularity: .day) == .orderedSame } ) {
                        ordersStructure.orders?.append(order)
                    } else {
                        let ordersStructure = OrdersForDate(date: order.startDate, orders: [order])
                        self?.ordersForDate.append(ordersStructure)
                    }
                }
                DispatchQueue.main.async {
                    self?.ordersTableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            }
        }
        
    }
    
    @objc private func addButtonTapped() {
        coordinator?.showServicesForClient(fromScreen: self)
    }
    //MARK: -
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension OrderedServicesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isFiltering {
            return ordersForDate.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isFiltering {
            return ordersForDate[section].orders?.count ?? 0
        } else {
            return filteredOrders.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !isFiltering {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            return dateFormatter.string(from: ordersForDate[section].date)
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ordersTableView.dequeueReusableCell(withIdentifier: Constants.CellIDs.orderCell, for: indexPath) as? OrderTableViewCell
        if !isFiltering {
            guard let order = ordersForDate[indexPath.section].orders?[indexPath.row] else {
                return UITableViewCell()
            }
            cell?.configure(forOrder: order)
        } else {
            let order = filteredOrders[indexPath.row]
            cell?.configure(forOrder: order)
        }
        cell?.delegate = self
        if showingContentFor == .client {
            cell?.hideDoneButton()
        }
        
        return cell ?? UITableViewCell()
    }
    //MARK: -
}

//MARK: - OrderTableViewCellDelegate
extension OrderedServicesViewController: OrderTableViewCellDelegate {
    func completeOrder(forCell cell: UITableViewCell) {
        if !isFiltering {
            if let indexPath = ordersTableView.indexPath(for: cell) {
                if let order = ordersForDate[indexPath.section].orders?[indexPath.row] {
                    do {
                        try DataService.shared.delete(order: order)
                        let timeInterval = Date().timeIntervalSince(order.startDate)
                        let service = try? ServiceEntity.find(serviceName: order.serviceName, serviceProviderID: order.providerID, context: DataService.shared.persistentContainer.viewContext)
                        let price = ((timeInterval / 60) / 60) * (service?.pricePerHour?.doubleValue ?? 0)
                        let alert = UIAlertController(title: "Completed order", message: "you earned \(price)$", preferredStyle: .alert)
                        let providerMoney = service?.toProvider?.money?.adding(NSDecimalNumber(value: price))
                        coordinator?.currentUser?.money = providerMoney! as Decimal
                        service?.toProvider?.money = providerMoney
                        let client = try? ClientEntity.find(userId: order.clientID, context: DataService.shared.persistentContainer.viewContext)
                        let clientMoney = client?.money?.subtracting(NSDecimalNumber(value: price))
                        client?.money = clientMoney
                        present(alert, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            alert.dismiss(animated: true, completion: nil)
                        }
                        ordersForDate[indexPath.section].orders?.remove(at: indexPath.row)
                        ordersTableView.beginUpdates()
                        
                        ordersTableView.deleteRows(at: [indexPath], with: .automatic)
                        if ordersForDate[indexPath.section].orders?.isEmpty ?? true {
                            ordersForDate.remove(at: indexPath.section)
                            ordersTableView.deleteSections([indexPath.section], with: .automatic)
                        }
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        ordersTableView.endUpdates()
                    } catch {
                        print(error)
                    }
                }
            }
        } else {
            if let indexPath = ordersTableView.indexPath(for: cell) {
                let order = filteredOrders[indexPath.row]
                do {
                    try DataService.shared.delete(order: order)
                    for date in ordersForDate {
                        date.orders?.removeAll(where: { (order) -> Bool in
                            return order === filteredOrders[indexPath.row]
                        })
                    }
                    filteredOrders.remove(at: indexPath.row)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    let timeInterval = Date().timeIntervalSince(order.startDate)
                    let service = try? ServiceEntity.find(serviceName: order.serviceName, serviceProviderID: order.providerID, context: DataService.shared.persistentContainer.viewContext)
                    let price = ((timeInterval / 60) / 60) * (service?.pricePerHour?.doubleValue ?? 0)
                    let alert = UIAlertController(title: "Completed order", message: "you earned \(price)", preferredStyle: .alert)
                    present(alert, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        alert.dismiss(animated: true, completion: nil)
                    }
                } catch {
                    print(error)
                }
                
            }
        }
    }
}
//MARK: -

extension OrderedServicesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredOrders = []
        for ordersDate in ordersForDate {
            for order in ordersDate.orders ?? [] {
                let service = try? ServiceEntity.find(serviceName: order.serviceName, serviceProviderID: order.providerID, context: DataService.shared.persistentContainer.viewContext)
                if service?.name?.lowercased().contains(searchText.lowercased()) ?? false || service?.category?.name?.lowercased().contains(searchText.lowercased()) ?? false {
                    filteredOrders.append(order)
                    print("did append")
                } else if order.providerName?.lowercased().contains(searchText.lowercased()) ?? false {
                    filteredOrders.append(order)
                    print("did append")
                } else if order.clientName?.lowercased().contains(searchText.lowercased()) ?? false {
                    filteredOrders.append(order)
                    print("did append")
                }
            }
        }
        ordersTableView.reloadData()
    }
}
