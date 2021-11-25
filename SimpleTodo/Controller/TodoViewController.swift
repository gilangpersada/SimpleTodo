//
//  TodoViewController.swift
//  SimpleTodo
//
//  Created by Gilang Persada on 23/11/2021.
//

import UIKit
import RealmSwift

class TodoViewController: UITableViewController {

    var todos:Results<Todo>?
    let realm = try! Realm()
    var selectedCategory:Category?{
        didSet{
            loadTodos()
        }
    }

    @IBOutlet weak var infoBarButton: UIBarButtonItem!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setup()
        
    }
    
    func setup(){
        tableView.rowHeight = 60
        
        let handler:(_ action:UIAction) -> () = {action in
            
            switch action.identifier.rawValue {
            case "isDone":
                self.handlerMenu(identifier: "isDone")
                
            case "notDone":
                self.handlerMenu(identifier: "notDone")
                
            case "all":
                self.handlerMenu(identifier: "all")
                
            default:
                print("default")
            }
        }
        
        let action = [
            UIAction(title: "Only is done", image: UIImage(systemName: "checkmark.square"), identifier: UIAction.Identifier("isDone"),   handler: handler),
            UIAction(title: "Only not done",image: UIImage(systemName: "square"), identifier: UIAction.Identifier("notDone"),   handler: handler),
            UIAction(title: "All", image: UIImage(systemName: "square.grid.2x2"), identifier: UIAction.Identifier("all"),   handler: handler)
        ]
        
        infoBarButton.menu = UIMenu(title: "Filter Setting", children: action)
        
    }
    
    func handlerMenu(identifier:String){
        switch identifier {
        case "isDone":
            todos = selectedCategory?.todos.filter("isDone == true", "isDone").sorted(byKeyPath: "createdAt", ascending: false)
            tableView.reloadData()
            
        case "notDone":
            todos = selectedCategory?.todos.filter("isDone == false", "isDone").sorted(byKeyPath: "createdAt", ascending: false)
            tableView.reloadData()
            
        case "all":
            todos = selectedCategory?.todos.sorted(byKeyPath: "createdAt", ascending: false)
            tableView.reloadData()
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if let todos = todos{
                if todos.count == 0{
                    return 1
                } else {
                    return todos.count
                }
            } else {
                return 0
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let todos = todos{
            if todos.count != 0{
                let todo = todos[indexPath.row]
                self.setIsDoneTodo(todo: todo)
                tableView.reloadData()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        
        if let todos = todos{
            if todos.count == 0{
                cell.textLabel?.text = ""
                cell.accessoryType = .none
                cell.selectionStyle = .none
            } else {
                let todo = todos[indexPath.row]
                cell.textLabel?.text = todo.title
                cell.accessoryType = todo.isDone ? .checkmark : .none
                cell.textLabel?.textColor = todo.isDone ? .gray : .label
                cell.selectionStyle = .default
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            if let todos = self.todos{
                if todos.count != 0{
                    let todo = todos[indexPath.row]
                    self.deleteTodo(todo: todo)
                }
            }
            handler(true)
        }
        
        action.backgroundColor = .systemRed
        
        let swipe = UISwipeActionsConfiguration(actions: [action])
        if let todos = todos{
            if todos.count != 0{
                return swipe
            } else {
                return nil
            }
            
        } else {
            return nil
        }
        
    }

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Todo", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let txtField = textField.text{
                if txtField.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                    let todo = Todo()
                    todo.title = txtField
                    todo.createdAt = Date()
                    if let currentCategory = self.selectedCategory{
                        self.saveTodo(todo: todo, currentCategory: currentCategory)
                    }
                }
                
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Todo title"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func infoPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    func loadTodos(){
        todos = selectedCategory?.todos.sorted(byKeyPath: "createdAt", ascending: false)
        tableView.reloadData()
    }
    
    func deleteTodo(todo:Todo){
        do{
            try realm.write{
                realm.delete(todo)
            }
            tableView.reloadData()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func saveTodo(todo:Todo, currentCategory:Category){
        do{
            try realm.write{
                currentCategory.todos.append(todo)
            }
            tableView.reloadData()
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func setIsDoneTodo(todo:Todo){
        do{
            try realm.write{
                todo.isDone = !todo.isDone
            }
            tableView.reloadData()
        } catch{
            print(error.localizedDescription)
        }
    }
}

extension TodoViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text{
            todos = selectedCategory?.todos.filter("title CONTAINS[cd] %@", searchBarText).sorted(byKeyPath: "createdAt", ascending: true)
            
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadTodos()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}
