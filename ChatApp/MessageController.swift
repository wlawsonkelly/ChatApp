//
//  MessageController.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class MessageController: UITableViewController  {
 
    
 
    //ADD COLLECTION CALLED USER MESSAGE OR SOMETING TO DOCUMENT SO ONLY GET ONE MESSAGE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellId = "cellId"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .plain, target: self, action:#selector(handleNewMessage))
        navigationItem.title = "Messages"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //fetchUserAndSetupNavBarTitle()
        
        //observeUserMessages()
        observeMessages()
    }
    
    @objc fileprivate func handleBack() {
       let profController = ProfilePageViewController()
        present(profController, animated: true)
    }
    
   
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        Firestore.firestore().collection("messages").whereField("toId", isEqualTo: uid).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("HELLLLLLLLNO", err)
            }
            
            //need to use where call and set it to from id
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let message = Message(dictionary: userDictionary)
                self.messages.append(message)
                self.fetchUserAndSetupNavBarTitle()
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                let messageStuff = Message(dictionary: userDictionary)
                
                if let chatPartnerId = messageStuff.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                        //refactor to cut cost
                    })
                }
                
                self.timer?.invalidate()
                print("we just canceled our timer")
                
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                
                
            })
            
        })
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            print("we reloaded the table")
            self.tableView.reloadData()
        })
    }
    //                Database.database().reference().child("messages").child(messageId)
    
    //            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
    //
    //                if let dictionary = snapshot.value as? [String: AnyObject] {
    //                    let message = Message(dictionary: dictionary)
    //
    //                    if let toId = message.toId {
    //                        self.messagesDictionary[toId] = message
    //
    //                        self.messages = Array(self.messagesDictionary.values)
    //                        self.messages.sort(by: { (message1, message2) -> Bool in
    //
    //                            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
    //                        })
    //                    }
    //
    //                    //this will crash because of background thread, so lets call this on dispatch_async main thread
    //                    DispatchQueue.main.async(execute: {
    //                        self.tableView.reloadData()
    //                    })
    //                }
    //
    //            }, withCancel: nil)
    //
    //        }, withCancel: nil)
    
    
    func observeMessages() {
        self.fetchUserAndSetupNavBarTitle()
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        //Figure out the problem here you genious
        
        Firestore.firestore().collection("messages").whereField("fromId", isEqualTo: uid).getDocuments(completion: { (snapshot, err) in
            if let err = err {
                print("FAILLLLLLLLL", err)
            }
            
            //need to use where call and set it to from id
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let message = Message(dictionary: userDictionary)
                self.messages.append(message)
                
                self.messages.sort(by: { (message1, message2) -> Bool in
                    return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                })
                //this will crash because of background thread, so lets call this on dispatch_async main thread
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    
                })
                
                //changeHandler: nil)
            })
            
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    var users = [User]()
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        //let user = users[indexPath.row]
        
        let message = messages[indexPath.row]
        cell.message = message
        
        //        let message = messages[indexPath.row]
        //        cell.textLabel?.text = message.toName
        //        cell.detailTextLabel?.text = message.text
        //
        //        if let profileImageUrl = user.imageUrl1 {
        //            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        //        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        //        let ref = Database.database().reference().child("users").child(chatPartnerId)
        //
        //        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //            guard let dictionary = snapshot.value as? [String: AnyObject] else {
        //                return
        //            }
        Firestore.firestore().collection("users").document(chatPartnerId).getDocument(completion: { (snapshot, err) in
            guard let dictionary = snapshot?.data() as [String: AnyObject]? else {return}
            
            
            var user = User(dictionary: dictionary)
            user.uid = chatPartnerId
            self.showChatControllerForUser(user)
            
        })
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        
        //        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            
            if let dictionary = snapshot?.data() {
                self.navigationItem.title = dictionary["Full Name"] as? String
                
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
        }
        
    }
    
    func setupNavBarWithUser(_ user: User) {
        //observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.redColor()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.imageUrl1 {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
}
