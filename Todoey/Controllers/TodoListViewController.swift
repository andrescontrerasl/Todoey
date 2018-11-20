//
//  ViewController.swift
//  Todoey
//
//  Created by Andres Contreras on 30/10/18.
//  Copyright © 2018 Andres Contreras. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    //var itemArray = [Item]()
    var itemArray : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        
        didSet{
            loadItems()
        }
    }
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    //let defaults = UserDefaults.standard
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
       
        tableView.separatorStyle = .none
        
        
        
        //loadItems()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
            
        title = selectedCategory!.name
        
        guard let colourHex = selectedCategory?.bgcolor else { fatalError() }
        
        //
        updateNavBar(withHexCode: colourHex)
        
        
                //navigationController?.navigationBar.barTintColor = UIColor(hexString: colourHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
        
        
    }
    
    //MARK: - NAv Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("navigation controller does not exist")
        }
        
        
        
        if let navBarColor = UIColor(hexString: colourHexCode) {
            
            navBar.barTintColor = navBarColor
            
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
            
            searchBar.barTintColor = UIColor(hexString: colourHexCode)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "ToDoItemCell")
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let itemBgColour = UIColor(hexString: selectedCategory?.bgcolor ?? "F3F3F3")?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(itemArray!.count)) {
                
                cell.backgroundColor = itemBgColour
                cell.textLabel?.textColor = ContrastColorOf(itemBgColour, returnFlat: true)
                
            }
            
            
        } else {
            cell.textLabel?.text = "No Items"
        }
        
        /*
        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
         */
        //Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
       
        
        return cell
        
    }
    
    //MARK - Tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        if let item = itemArray?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item)
                }
            } catch {
                print("error updating done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        
        /*
        if itemArray[indexPath.row].done == false {
            itemArray[indexPath.row].done = true
        } else {
            itemArray[indexPath.row].done = false
        }
        */
        // instead of if and else we can use :
        
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done // this means the opposite, true or false
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        
        //saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todory item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen when user click the add item button
           
            if textField.text != ""  {
            
                
                if let  currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            
                            newItem.title = textField.text!
                            currentCategory.items.append(newItem)
                            newItem.dateCreated = Date()
                            self.realm.add(newItem)
                        }
                    } catch {
                        print("error saving item \(error)")
                    }
                    
                   // self.saveItems(item: newItem)
                }
                self.tableView.reloadData()
                
                
//
//                let newItem = Item(context: self.context)
//
//                newItem.title = textField.text!
//                newItem.done = false
//                newItem.parentCategory = self.selectedCategory
//
//                self.itemArray.append(newItem)
//
//                self.saveItems()
                
            }
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manipulation Methods
    
    func saveItems(item: Item){
        
        do {
            //try context.save()
            try realm.write {
                realm.add(item)
            }
            
        } catch {
            
            print("error saving item \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    func loadItems(){
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
    //MARK: - delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemForDeletion = itemArray?[indexPath.row]{
            
            do{
                try realm.write {

                    realm.delete(itemForDeletion)

                }
                
                print("item deleted")

            } catch {
                print("error deleting category \(error)")
            }
            
        }
    }
    
    
    
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
//        } else {
//          request.predicate = categoryPredicate
//        }
//
//
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data from vontext \(error)")
//        }
//
//        tableView.reloadData()
//    }
//
    
    
    
//    func loadItems(){
//
//
//        if let data = try? Data(contentsOf: dataFilePath!) {
//
//            let decoder = PropertyListDecoder()
//
//            do {
//                itemArray = try decoder.decode([Item].self, from: data)
//
//            } catch {
//                print("error decoding item array ,\(error)")
//            }
//
//
//        }
//
//    }
    

}
//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        //let request : NSFetchRequest<Item> = Item.fetchRequest()

        //let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text! )

        /*
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)

        request.sortDescriptors = [sortDescriptor]
         */

        //request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        //loadItems(with: request, predicate: predicate)

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
