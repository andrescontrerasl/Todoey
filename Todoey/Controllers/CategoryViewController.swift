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


class CategoryViewController: UITableViewController {

    let realm = try! Realm()
    
    //var categoryArray = [Category]()
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        
        
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
