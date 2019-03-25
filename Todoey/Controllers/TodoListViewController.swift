//
//  ViewController.swift
//  Todoey
//
//  Created by Prince Thomas on 9/3/19.
//  Copyright © 2019 Prince Thomas. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    var todoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category?{
        didSet{
               loadItems()
        }
    }
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
          //  cell.backgroundColor = UIColor(hexString: todoItems?[indexPath.row].color ?? UIColor.randomFlat.hexValue())
           
            if let color = UIColor(hexString: (selectedCategory!.color))?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
             return cell
        
    }
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//        saveItems()
        
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print ("Error saving context, \(error)")
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()

    }

   //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default){(action) in

            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        newItem.color = UIColor.randomFlat.hexValue()
                        
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print ("Error saving context, \(error)")
                }
            }
            
              self.tableView.reloadData()
      
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true, completion: nil)

    }

    
    func loadItems() {

        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let selectedItem = self.todoItems?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(selectedItem)
                }
            } catch {
                print ("Error saving context, \(error)")
            }
        }
    }
}

// MARK : - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

 //   func searchBarSearchButtonClicked(_ searchBar: UISearchBar)

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.count == 0) {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        } else {
            searchBar.delegate = self
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }

}

