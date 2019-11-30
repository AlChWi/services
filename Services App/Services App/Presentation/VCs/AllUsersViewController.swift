//
//  AllUsersViewController.swift
//  Services App
//
//  Created by Алексей Перов on 30.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit
import SnapKit

class AllUsersViewController: UIViewController {
    
    private lazy var usersTableView = { () -> UITableView in
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    private var users: [UserModel] = [] {
        didSet {
            usersTableView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(usersTableView)
        usersTableView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
}

extension AllUsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let user = users[indexPath.row]
        let userEntity = DataService.shared.findUser(byID: user.id)
        if let providerEntity = userEntity as? ProviderEntity {
            let profession = providerEntity.profession
            cell.detailTextLabel?.text = "\(profession?.name ?? "")"
        }
        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        return cell
    }
}
