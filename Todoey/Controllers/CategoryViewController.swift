//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Prince Thomas on 11/3/19.
//  Copyright © 2019 Prince Thomas. All rights reserved.
//

import UIKit
import RealmSwift
import CoreData

class CategoryViewController: UITableViewController {
    let realm = try! Realm()
    var categories : Results<Category>?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories?.count ?? 1

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
//            contextCategory.delete(categoryArray[indexPath.row])
//            realm.delete(categoryArray[indexPath.row])
//            categoryArray.remove(at: indexPath.row)
            self.tableView.reloadData()
//            saveCategories()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
 
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default){(action) in
            print("Success")
            
            
            let newCategory = Category()
            newCategory.name = textField.text!

            self.save(category: newCategory)
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true, completion: nil)

    }
    func save(category: Category) {
        do{
            try realm.write {
                realm.add(category)
            }
        } catch {
            print ("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
   func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
}
