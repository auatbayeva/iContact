//
//  ViewController.swift
//  iContact
//
//  Created by Айбану Уатбаева on 01.10.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var selectedIndex: Int = 0
    var sections: [Section] = []
    static let storageKey: String = "Contacts"
     override func viewDidLoad() {
         super.viewDidLoad()
        
         tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: ContactTableViewCell.identifier)
         tableView.dataSource = self
         tableView.delegate = self
         tableView.refreshControl = UIRefreshControl()
         tableView.refreshControl?.addTarget(self, action: #selector(sortArray), for: .valueChanged)
        
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortArray()
    }
    
    

    @IBAction func AddContactButtonPressed(_ sender: Any) {
        askForAddContact()
    }
    @IBAction func changeSegmentedControl(_ sender: Any) {
        selectedIndex = segmentedControl.selectedSegmentIndex
        sortArray()
    }
    
    func askForAddContact(){
        let alertController = UIAlertController(title: "Add Contact", message: nil, preferredStyle: .alert)
        alertController.addTextField { firstNameTextField in
            firstNameTextField.placeholder = "First name"
        }
        alertController.addTextField { lastNameTextField in
            lastNameTextField.placeholder = "Last name"
        }
        alertController.addTextField { phoneTextField in
            phoneTextField.placeholder = "Phone"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Add", style: .default){_ in
            guard let firstNameTextField = alertController.textFields?[0], let lastNameTextField = alertController.textFields?[1], let phoneTextField = alertController.textFields?[2] else {
                print("First name text field | Last name text field | Phone number text filed is absent")
                return
            }
            
            guard let firstName = firstNameTextField.text,  !firstName.isEmpty else {
                print("First name is nil or absent")
                return
            }
            guard let lastName = lastNameTextField.text, !lastName.isEmpty else {
                print("Last name is nil or absent")
                return
            }
            guard let phoneNumber = phoneTextField.text, !phoneNumber.isEmpty else {
                print("Phone number is nil or absent")
                return
            }
            guard self.isValidPhone(phone: phoneNumber) else {
                print("Incorrect phone number")
                return
            }
            self.saveContactAsStruct(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
            print(ViewController.getAllContacts())
            
        }
        alertController.addAction(saveAction)
        
        
        present(alertController,animated: true)
        
        
    }
    
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    func saveContactAsStruct(firstName: String, lastName: String, phoneNumber: String){
        let contact: Contact = Contact(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber)
        
        let contactArray: [Contact] = ViewController.getAllContacts()  + [contact]
        do {
            
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(contactArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encoded, forKey: ViewController.storageKey)
            
        } catch {
            
            print("Coludn't encode given [Contact] into data with error: \(error.localizedDescription)")
            
        }
        sortArray()
        
    }
    
    
     static func getAllContacts()->[Contact]{
        var result: [Contact] = []
        
        let userDefaults = UserDefaults.standard
         if let data = userDefaults.object(forKey: ViewController.storageKey) as? Data {
            
            do {
                
                let decoder = JSONDecoder()
                result = try decoder.decode([Contact].self, from: data)
                
            } catch {
                print("Couldn't decode given data to [Contact] with error: \(error.localizedDescription)")
            }
        }
        
        return result
    }
    @objc
    func sortArray(){
        
        let contacts = ViewController.getAllContacts()
        sections = []
        for contact in contacts {
            var char = "\(contact.firstName.prefix(1))"
            if selectedIndex == 1 {
                char = "\(contact.lastName.prefix(1))"
            }
            if !sections.contains(where: { Section in
                Section.letter == char
            }){
                sections.append(Section(letter: char, contacts: [contact]))
            }else{
                
                if let index = sections.firstIndex(where: { $0.letter == char }) {
                    var sectionContacts = sections[index].contacts
                    sectionContacts.append(contact)
                    sections[index].contacts = sectionContacts
                }
            }
        }
        sections.sort{ $0.letter < $1.letter }
        tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
        
    }
 
}
//MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier, for: indexPath) as! ContactTableViewCell
        let contact = sections[indexPath.section].contacts[indexPath.row]
        var text = "\(contact.firstName) \(contact.lastName)"
        if selectedIndex == 1 {
            text = "\(contact.lastName) \(contact.firstName)"
        }
        cell.contactTextLabel.text = text 
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].letter
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ContactViewController()
        let contact = sections[indexPath.section].contacts[indexPath.row]
        viewController.phone = contact.phoneNumber
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
}
struct Contact: Codable {
    let firstName: String
    let lastName: String
    let phoneNumber: String
}
struct Section {
    let letter : String
    var contacts : [Contact]
  
}
 


