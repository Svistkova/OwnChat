//
//  ChatViewController.swift
//  OwnChat
//
//  Created by Marina Svistkova on 08.04.2020.
//  Copyright © 2020 Marina Svistkova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messageArray : [Message] = [Message]()

    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextfield.delegate = self
        

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }

    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatTeal()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    

    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    //MARK:- TextField Delegate Methods
    
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    

    //MARK: - Send & Recieve from Firebase
 
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        //Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary){
            (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print ("Message Saved Successfully!")
            }
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextfield.text = ""
        }
        
        
    }
    
    //retrieveMessages method
    
    func retrieveMessages() {
    let messagesDB = Database.database().reference().child("Messages")
        
        messagesDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let message = Message()
            message.messageBody = text
            message.sender = sender
            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
            
            
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
        try Auth.auth().signOut()
            
            navigationController?.popToRootViewController(animated: true)
        }
        catch {
            print("Error. There was a problem with signing out")
        }
    }
    
    

}
