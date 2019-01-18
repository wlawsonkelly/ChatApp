//
//  ProfilePageViewController.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

extension ProfilePageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func  imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        profPicView.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

class ProfilePageViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate {
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
   
    let topStackView = ProfPageTopStackView()
    let profPicView = ProfPageMiddleView()
   
    
    
    @objc func handleSelectPhoto () {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsTableViewController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true)
        
    }
    

    
    @objc func handleMessages() {
        let messageController = MessageController()
        let navController = UINavigationController(rootViewController: messageController)
        present(navController, animated: true)
        
    }
    
    
    func didSaveSettings() {
        print("Notified of dismissal")
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeController did appear")
        // you want to kick the user out when they log out
        if Auth.auth().currentUser == nil {
            let loginController = LoginViewController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            present(navController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchCurrentUser()
        
        view.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        
        topStackView.homeButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)

        profPicView.selectPhotoButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
     
        topStackView.messageButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        setupLayout()
        
    }
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            //print(snapshot?.data())
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            self.loadUserPhotos()
        }
    }
    
    let tippyTop: UIView = {
        let tT = UIView()
        tT.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tT.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        return tT
    }()
    
    var user: User?
    
    fileprivate func loadUserPhotos() {
        guard let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) else {return}
        SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
            self.profPicView.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //self.user?.imageUrl1
    }
    
    fileprivate func setupLayout () {
        
        let overallStackView = UIStackView(arrangedSubviews: [tippyTop, topStackView, profPicView])
        view.addSubview(overallStackView)
        
        overallStackView.axis = .vertical
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: -20, left: 0, bottom: 50, right: 0)
    }
    
 
    
}
