//
//  CategorySelectionViewController.swift
//  Services App
//
//  Created by Алексей Перов on 25.11.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import UIKit
import SnapKit

class CategorySelectionViewController: UIViewController {

    var coordinator: MainCoordinator?
    var categoriesTableView = UITableView()
    var categories: [ServiceCategoryModel] = [] {
        didSet {
            categoriesTableView.reloadData()
        }
    }
    var filteredCategories: [ServiceCategoryModel] = [] {
        didSet {
            categoriesTableView.reloadData()
        }
    }
    var isSearchBarEmpty: Bool {
        searchBarController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchBarController.isActive && !isSearchBarEmpty
    }
    
    private lazy var addCategoryButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategory))
    private lazy var searchBarController = UISearchController(searchResultsController: nil)
    
    override func loadView() {
        self.view = UIView()
        view.backgroundColor = .white
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = addCategoryButton
        navigationItem.searchController = searchBarController
        
        searchBarController.searchResultsUpdater = self
        searchBarController.obscuresBackgroundDuringPresentation = false
        searchBarController.searchBar.placeholder = "Category name"
        definesPresentationContext = true
        
        let categoryEntities = try? ServiceCategoryEntity.findAll(context: DataService.shared.persistentContainer.viewContext)
        categories = categoryEntities?.compactMap { ServiceCategoryModel(entity: $0) } ?? []

        view.addSubview(categoriesTableView)
        categoriesTableView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.leading.equalToSuperview()
        }
        // Do any additional setup after loading the view.
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        categoriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    func addCategory() {
        let alert = UIAlertController(title: "Category", message: "Add category", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.tag = 1
            textField.placeholder = "name"
        })
        alert.addTextField(configurationHandler: { (textField) in
            textField.tag = 2
            textField.placeholder = "Hours it usually takes"
        })
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            guard
                let nameText = alert.textFields?.first?.text,
                let hoursCategoryTakesText = alert.textFields?[1].text,
                let hoursCategoryTakes = Double(hoursCategoryTakesText) else {
                    return
            }
            let categoryModel = ServiceCategoryModel(name: nameText, standardLength: hoursCategoryTakes)
            do {
                try ServiceCategoryEntity.findOrCreate(categoryModel, context: DataService.shared.persistentContainer.viewContext)
            } catch CategoryCreationError.alreadyExisted {
                let alert = UIAlertController(title: "Error", message: "Category already exists", preferredStyle: .alert)
                self.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    alert.dismiss(animated: true, completion: nil)
                }
            } catch {
                return
            }
            self.categories.append(categoryModel)
            try? DataService.shared.persistentContainer.viewContext.save()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        present(alert, animated: true)
    }
}

extension CategorySelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredCategories = categories.filter({ (category) -> Bool in
            return category.name.lowercased().contains(searchText.lowercased())
        })
      
      categoriesTableView.reloadData()
    }
    
}

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredCategories.count
        } else {
            return categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if isFiltering {
            cell.textLabel?.text = "\(filteredCategories[indexPath.row].name) takes \(filteredCategories[indexPath.row].standardLength ?? 0) hours"
        } else {
            cell.textLabel?.text = "\(categories[indexPath.row].name) takes \(categories[indexPath.row].standardLength ?? 0) hours"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if isFiltering {
                let category = try? ServiceCategoryEntity.find(categoryName: filteredCategories[indexPath.row].name, context: DataService.shared.persistentContainer.viewContext)
                DataService.shared.persistentContainer.viewContext.delete(category!)
                categories.removeAll { (category) -> Bool in
                    return category.name == filteredCategories[indexPath.row].name
                }
                filteredCategories.remove(at: indexPath.row)
            } else {
                let category = try? ServiceCategoryEntity.find(categoryName: categories[indexPath.row].name, context: DataService.shared.persistentContainer.viewContext)
                DataService.shared.persistentContainer.viewContext.delete(category!)
                categories.remove(at: indexPath.row)
            }
            try? DataService.shared.persistentContainer.viewContext.save()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            NotificationCenter.default.post(name: .categorySelected, object: nil, userInfo: ["category" : filteredCategories[indexPath.row]])
        } else {
            NotificationCenter.default.post(name: .categorySelected, object: nil, userInfo: ["category" : categories[indexPath.row]])
        }
        navigationController?.popViewController(animated: true)
    }
}
