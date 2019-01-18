//
//  SettingsTableViewController.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class CustomImagePickerController: UIImagePickerController {
    var imageBttn: UIButton?
}

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: SettingsControllerDelegate?
    
    lazy var image1Button = createBttn(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createBttn(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createBttn(selector: #selector(handleSelectPhoto))
    
    @objc func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageBttn = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        
        let imageButton = (picker as? CustomImagePickerController)?.imageBttn
        
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true)
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image..."
        hud.show(in: view)
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else {return}
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            hud.dismiss()
            if let err = err {
                print("Failed to upload photo", err)
                hud.dismiss()
                return
            }
            ref.downloadURL(completion: { (url, err) in
                hud.dismiss()
                if let err = err {
                    print("Failed to download url", err)
                    return
                }
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                }
                else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
            })
        }
    }
    
    
    func createBttn(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleToFill
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupGradientLayer()
        setUpNavItems()
        tableView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        //setupGradientLayer()
        fetchCurrentUser()
        
    }
    
    // let hud = JGProgressHUD(style: .light)
    
    var user: User?
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            print(snapshot?.data() ?? "fuck you")
            guard let dictionary = snapshot?.data() else {return}
            self.user = User(dictionary: dictionary)
            self.loadUserPhotos()
            
            self.tableView.reloadData()
            
        }
        
    }
    
    fileprivate func loadUserPhotos() {
        
        //maybe refactor this
        
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
            //self.user?.imageUrl1
        }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            return header
//        }
        let headerLabel = HeaderLabel()
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2 :
            headerLabel.text = "School"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Hello there, welcome to settings"
        }
        return headerLabel
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     
        return 45
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingsCells(style: .default, reuseIdentifier: nil)
        
//        if indexPath.section == 5 {
//            let ageRangeCell = AgeRangeTableViewCell(style: .default, reuseIdentifier: nil)
//            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinChanged), for: .valueChanged)
//            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxChanged), for: .valueChanged)
//
//            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? 18)"
//            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? 50)"
//
//            ageRangeCell.minSlider.value = Float(user?.minSeekingAge ?? 18)
//            ageRangeCell.maxSlider.value = Float(user?.maxSeekingAge ?? 50)
//
//            return ageRangeCell
//        }
//        else if indexPath.section == 6 {
//            let locationRangeCell = LocationTableViewCell(style: .default, reuseIdentifier: nil)
//
//            return locationRangeCell
//        }
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2 :
            cell.textField.placeholder = "School"
            cell.textField.text = user?.school
            cell.textField.addTarget(self, action: #selector(handleSchoolChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Age"
            if let age = user?.age {
                cell.textField.text = String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
        case 4:
            cell.textField.placeholder = "Bio"
            cell.textField.text = user?.bio
            cell.textField.addTarget(self, action: #selector(handleBioChange), for: .editingChanged)
        default:
            cell.textField .placeholder = "age stuff"
        }
        
        
        return cell
    }
    
//    @objc fileprivate func handleMinChanged (slider: UISlider) {
//        
//        evaluateMinMax()
//    }
//    
//    @objc fileprivate func handleMaxChanged (slider: UISlider) {
//        
//        evaluateMinMax()
//    }
    
    
//    fileprivate func evaluateMinMax() {
//        guard let ageRangeCell = tableView.cellForRow(at: [5, 0]) as? AgeRangeTableViewCell else { return }
//        let minValue = Int(ageRangeCell.minSlider.value)
//        var maxValue = Int(ageRangeCell.maxSlider.value)
//        maxValue = max(minValue, maxValue)
//        ageRangeCell.maxSlider.value = Float(maxValue)
//        ageRangeCell.minLabel.text = "Min \(minValue)"
//        ageRangeCell.maxLabel.text = "Max \(maxValue)"
//        
//        user?.minSeekingAge = minValue
//        user?.maxSeekingAge = maxValue
//    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        print("name changing")
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleSchoolChange(textField: UITextField) {
        self.user?.school = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleBioChange(textField: UITextField) {
        self.user?.bio = textField.text
    }
    
    fileprivate func setUpNavItems() {
        navigationItem.title = "Settings "
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleBack))
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogOut))
        ]
    }
    
    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        let docData: [String: Any] = [
            "uid": uid,
            "Full Name": user?.name ?? "",
            "ImageUrl1": user?.imageUrl1 ?? "",
            "ImageUrl2": user?.imageUrl2 ?? "",
            "ImageUrl3": user?.imageUrl3 ?? "",
            "Age": user?.age ?? -1,
            "School": user?.school ?? "",
            "Bio": user?.bio ?? "",
            "minSeekingAge": user?.minSeekingAge ?? 18,
            "maxSeekingAge": user?.maxSeekingAge ?? 50,
            ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving Changes"
        hud.show(in: view)
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err)
            in
            hud.dismiss()
            if let err = err {
                print("Failed to retrieve user settings", err)
                return
            }
            self.dismiss(animated: true, completion: {
                print("Dismissal Complete")
                self.delegate?.didSaveSettings()
                
            })
        }
    }
    
    @objc fileprivate func handleLogOut() {
        let firebaseAuth = Auth.auth()
        let loginViewController = LoginViewController()
        let navController = UINavigationController(rootViewController: loginViewController)
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true)
        present(navController, animated: true)
    }
    
    @objc fileprivate func handleBack() {
        dismiss(animated: true)
    }
    
    
}
