//
//  CategoryViewController.swift
//  SimpleTodo
//
//  Created by Gilang Persada on 23/11/2021.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    var categories:Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        setup()
        navigationController?.navigationBar.barTintColor = .systemYellow
    }
    
    func setup(){
        tableView.rowHeight = 60
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let txtField = textField.text{
                if txtField.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                    let category = Category()
                    category.title = txtField
                    self.saveCategory(category: category)
                }
               
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category title"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let categories = categories{
            if categories.count == 0{
                return 1
            } else {
                return categories.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        
        if let categories = categories{
            if categories.count == 0{
                cell.textLabel?.text = "No Category Added Yet!"
                cell.accessoryType = .none
                cell.selectionStyle = .none
            } else {
                let category = categories[indexPath.row]
                cell.textLabel?.text = category.title
                
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            if let categories = self.categories{
                if categories.count != 0{
                    let category = categories[indexPath.row]
                    self.deleteCategory(category: category)
                }
            }
            
            handler(true)
        }
        
        action.backgroundColor = .systemRed
        
        let swipe = UISwipeActionsConfiguration(actions: [action])
        if let _ = categories{
            return swipe
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let categories = categories{
            if categories.count != 0{
                performSegue(withIdentifier: "goToTodo", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoViewController
        if let indexPath = tableView.indexPathForSelectedRow{
//            print(categories?[indexPath.row])
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    func saveCategory(category:Category){
        do{
            try realm.write{
                realm.add(category)
            }
            tableView.reloadData()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func deleteCategory(category:Category){
        do{
            try realm.write{
                realm.delete(category)
            }
            tableView.reloadData()
        } catch{
            print(error.localizedDescription)
        }
    }
    
}


