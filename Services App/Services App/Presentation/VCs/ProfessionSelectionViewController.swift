//
//  ProfessionSelectionViewController.swift
//  Services App
//
//  Created by Алексей Перов on 24.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit
import SnapKit

class ProfessionSelectionViewController: UIViewController {
    
    var coordinator: MainCoordinator?
    var professionsTableView = UITableView()
    var professions: [ProfessionModel] = [] {
        didSet {
            professionsTableView.reloadData()
        }
    }
    var filteredProfessions: [ProfessionModel] = [] {
        didSet {
            professionsTableView.reloadData()
        }
    }
    var isSearchBarEmpty: Bool {
        searchBarController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchBarController.isActive && !isSearchBarEmpty
    }
    
    private lazy var addProfessionButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProfession))
    private lazy var searchBarController = UISearchController(searchResultsController: nil)
    
    override func loadView() {
        self.view = UIView()
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = addProfessionButton
        navigationItem.searchController = searchBarController
        
        searchBarController.searchResultsUpdater = self
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.searchBar.placeholder = "Profession name"
        definesPresentationContext = true
        
        let professionEntities = try? ProfessionEntity.findAll(context: DataService.shared.persistentContainer.viewContext)
        professions = professionEntities?.compactMap { ProfessionModel(fromEntity: $0) } ?? []
        
        view.addSubview(professionsTableView)
        professionsTableView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        
        // Do any additional setup after loading the view.
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        professionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        professionsTableView.delegate = self
        professionsTableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc
    private func addProfession() {
        let alert = UIAlertController(title: "Profession", message: "Add Profession", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            guard
                let professionName = alert.textFields?.first?.text else {
                    alert.dismiss(animated: true, completion: nil)
                    return
            }
            let profession = ProfessionModel(name: professionName)
            do {
                try ProfessionEntity.findOrCreate(profession, context: DataService.shared.persistentContainer.viewContext)
            } catch ProfessionCreationError.alreadyExisted {
                let alert = UIAlertController(title: "Error", message: "Profession already exists", preferredStyle: .alert)
                self.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    alert.dismiss(animated: true, completion: nil)
                }
                return
            } catch {
                return
            }
            try? DataService.shared.persistentContainer.viewContext.save()
            self.professions.append(profession)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
//            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true)
    }
}

extension ProfessionSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredProfessions.count
        } else {
            return professions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = professionsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isFiltering {
            cell.textLabel?.text = filteredProfessions[indexPath.row].name
        } else {
            cell.textLabel?.text = professions[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            NotificationCenter.default.post(name: .professionSelected, object: nil, userInfo: ["profession" : filteredProfessions[indexPath.row]])
        } else {
            NotificationCenter.default.post(name: .professionSelected, object: nil, userInfo: ["profession" : professions[indexPath.row]])
        }
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let professionEntity: ProfessionEntity?
            if isFiltering {
                do {
                    professionEntity = try ProfessionEntity.find(professionName: filteredProfessions[indexPath.row].name, context: DataService.shared.persistentContainer.viewContext)
                } catch {
                    print("COULDN'T FIND ENTITY")
                    return
                }
                DataService.shared.persistentContainer.viewContext.delete(professionEntity!)
                professions.removeAll(where: { $0.name == filteredProfessions[indexPath.row].name })
                filteredProfessions.remove(at: indexPath.row)
            } else {
                do {
                    professionEntity = try ProfessionEntity.find(professionName: professions[indexPath.row].name, context: DataService.shared.persistentContainer.viewContext)
                } catch {
                    print("COULDN'T FIND ENTITY")
                    return
                }
                DataService.shared.persistentContainer.viewContext.delete(professionEntity!)
                professions.remove(at: indexPath.row)
            }
            try? DataService.shared.persistentContainer.viewContext.save()
        }
    }
}

extension ProfessionSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredProfessions = professions.filter({ (profession) -> Bool in
            return profession.name.lowercased().contains(searchText.lowercased())
        })
      
      professionsTableView.reloadData()
    }
    
}
