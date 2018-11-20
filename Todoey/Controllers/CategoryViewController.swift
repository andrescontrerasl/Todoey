//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Andres Contreras on 12/11/18.
//  Copyright © 2018 Andres Contreras. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    //var categoryArray = [Category]()
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.separatorStyle = .none

        
        //tableView.rowHeight = 80.0
        
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        
        //cell.delegate = self
        
        //cell.backgroundColor = UIColor.randomFlat
        
        
        if let celBgColor = categoryArray?[indexPath.row].bgcolor {
            //cell.backgroundColor = HexColor(celBgColor)
            cell.backgroundColor = UIColor(hexString: celBgColor)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: celBgColor)!, returnFlat: true)
        }
        
        //cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].bgcolor ?? "F3F3F3")
        
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    // trigger when we select on of the cells.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    
    
    // MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todoey category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen when user click the add item button
            
            if textField.text != ""  {
                
                
                let newCategory = Category()
                
                newCategory.name = textField.text!
                newCategory.bgcolor = UIColor.randomFlat.hexValue()
                //self.categoryArray.append(newCategory)
                
                self.save(category: newCategory)
                
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    //MARK: - Data Manipulation Methods
    func save(category: Category){
        
        do {
            //try context.save()
            try realm.write {
                realm.add(category)
            }
            
        } catch {
            
            print("error saving content \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    
    func loadCategories(){
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    
    //MARK: - delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write {

                    self.realm.delete(categoryForDeletion)

                }

                print("category deleted")

            } catch {
                print("error deleting category \(error)")
            }

            //removed this because options.expansionStyle = .destructive will remove the last cell
            //tableView.reloadData()
        }
    }
    
    
//    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
//        do {
//            categoryArray = try context.fetch(request)
//        } catch {
//            print("Error fetching categories \(error)")
//        }
//
//        tableView.reloadData()
//    }
    
}


