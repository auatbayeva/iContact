//
//  ContactViewController.swift
//  iContact
//
//  Created by Айбану Уатбаева on 02.10.2023.
//

import UIKit

class ContactViewController: UIViewController {
    

    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var NameSurnameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var pictureTextLabel: UILabel!
    @IBOutlet weak var phoneNumberButtonText: UIButton!
    var phone: String = ""
    var contact: Contact = Contact(firstName: "", lastName: "", phoneNumber: "")
    var index: Int = 0
    var timer: Timer?
    var countDown: Int = 5
    override func viewDidLoad() {
         super.viewDidLoad()
        
        pictureView.layer.cornerRadius = pictureView.frame.height / 2
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getContactByPhoneNumber()
        setData()
    }
    @IBAction func callButtonPressed(_ sender: Any) {
        callNumber()
    }
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        sendSMS()
    }
    @IBAction func callButton2Pressed(_ sender: Any) {
        callNumber()
    }
    @IBAction func callFaceTimeButtonPressed(_ sender: Any) {
        facetime()
    }
    @IBAction func undoButtonPressed(_ sender: Any) {
        timer?.invalidate()
        undoButton.isHidden = true
        progressView.isHidden = true
        deleteButton.isHidden = false
        countDown = 5
        progressView.progress = 0
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        undoButton.isHidden = false
        progressView.isHidden = false
        deleteButton.isHidden = true
        scheduleTimer()
        
    }
    
    func getContactByPhoneNumber(){
        let contacts = ViewController.getAllContacts()
        guard let index = contacts.firstIndex(where: { $0.phoneNumber == phone}) else { return }
        self.index = index
        contact = contacts[index]
    }
    func setData(){
        phoneNumberButtonText.setTitle( phone, for: .normal)
        NameSurnameLabel.text = "\(contact.firstName) \(contact.lastName)"
        pictureTextLabel.text = "\(contact.firstName.prefix(1))\(contact.lastName.prefix(1))"
    }
    
    private func callNumber() {
        guard let url = URL(string: "telprompt://\(phone)"),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    private func sendSMS() {
        let sms = "sms:\(phone)&body="
        let strURL = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        UIApplication.shared.open(URL(string: strURL)!, options: [:], completionHandler: nil)
     }
    private func facetime() {
      if let facetimeURL:NSURL = NSURL(string: "facetime://\(phone)") {
          let application:UIApplication = UIApplication.shared
          if (application.canOpenURL(facetimeURL as URL)) {
              application.openURL(facetimeURL as URL);
        }
      }
    }
    func deleteContact(){
        var contactArray: [Contact] = ViewController.getAllContacts()
        print(index)
        contactArray.remove(at: index)
        do {
            
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(contactArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encoded, forKey: ViewController.storageKey)
            
        } catch {
            
            print("Coludn't encode given [Contact] into data with error: \(error.localizedDescription)")
            
        }
        //navigationController?.popViewController(animated: true)
    }
    
    func scheduleTimer() {
        countDown = 5
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimerUI(){
        countDown -= 1
        progressView.progress = Float(5 - countDown) / 5
        
        if countDown <= 0 {
            deleteContact()
            navigationController?.popViewController(animated: true)
            timer?.invalidate()
        }
    }
    
}


 
