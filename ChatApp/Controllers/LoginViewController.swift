//
//  LoginViewController.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import FacebookLogin
import FBSDKLoginKit
import FacebookCore
import FBSDKCoreKit


class LoginViewController: UIViewController {
    
    var delegate: LoginControllerDelegate?
    
    
    let Text: UILabel = {
        let label = UILabel()
        
        label.text = "Chat with your friends unless you don't have any"
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    
    
    let LoginBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in with Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()
    
    
    
    let FBLoginBttn: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Log in with Facebook", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 27.5, weight: .heavy)
        button.backgroundColor = .blue
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLogin () {
        let enterInfoViewController = EnterInfoViewController()
        present(enterInfoViewController, animated: true)
    }
    let registrationViewModel = RegistrationViewModel()
    let registeringHUD = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleRegister() {
        
        let messageController = MessageController()
        registrationViewModel.performRegistration { [weak self] (err) in
            if let err = err {
                self?.showHUDWithError(error: err)
                return
            }
            self?.present(messageController, animated: true)
        }
    }
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self)  { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print("cccccccccccccccccccccccccccccccccccccc",error)
            case .cancelled:
                print("User cancelled login.")
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                print("Logged in!")
                self.performRegistration()
            }
            
        }
    }
    
    
    fileprivate func performRegistration() {
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, err) in
            if let err = err {
                print("There was an error bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", err)
                
                return
            }
            
            
            self.fetchFacebookUser()
        }
    }

    
    fileprivate func fetchFacebookUser() {
        let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
        req.start({ (connection, result) in
            switch result {
            case .failed(let error):
                print(error)
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    let firstNameFB = responseDictionary["first_name"] as? String
                    let lastNameFB = responseDictionary["last_name"] as? String
                    let socialIdFB = responseDictionary["id"] as? String
                    let genderFB = responseDictionary["gender"] as? String
                    let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
                    let photoData = pictureUrlFB!["data"] as? [String:Any]
                    let photoUrl = photoData!["url"] as? String
                    
                   
                    self.fullName = "\(firstNameFB ?? "") \(lastNameFB ?? "")"
                    self.photoUrl = photoUrl
                    
//                    let docData: [String: Any] =
//                        ["Full Name": name,
//                         "uid": uid,
//                         "School": "N/A",
//                         "Age": 1,
//                         "Bio": "",
//                         "minSeekingAge": 18,
//                         "maxSeekingAge": 50,
//                         "ImageUrl1": photoUrl as Any]
                    //let userAge = ["Age": age]
//                    Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
//                        //self.bindableIsRegistering.value = false
//                        if let err = err {
//                            print("hahahaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",err)
//                            return
//                        }
//                        let profileController = ProfilePageViewController()
//                        self.present(profileController, animated: true)
                    }
                }
            self.saveInfoToFirestore()
            
        })
    }
    
//    fileprivate func saveImageToFirebase(completion: @escaping (Error?) ->()) {
//
//        let filename = UUID().uuidString
//        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
//        let imageData = self.photoData.jpegData(compressionQuality: 0.75) ?? Data()
//        ref.putData(imageData, metadata: nil, completion: {(_, err) in
//            if let err = err {
//                completion(err)
//                return //bail
//            }
//            print("finished Uploading image")
//            ref.downloadURL(completion: { (url, err) in
//                if let err = err {
//                    completion(err)
//                    return
//                }
//                self.bindableIsRegistering.value = false
//                print("Download url of our image is:", url?.absoluteString ?? "")
//
//                let imageUrl = url?.absoluteString ?? ""
//                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
//            })
//        })
//    }

    var fullName: String?
    var school: String?
    var age: Int?
    var photoUrl: String?
    
    fileprivate func saveInfoToFirestore(){
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] =
            ["Full Name": fullName ?? "",
             "uid": uid,
             "School": school ?? "",
             "Age": age ?? 18,
             "Bio": "",
             "minSeekingAge": 18,
             "maxSeekingAge": 50,
             "ImageUrl1": photoUrl!]
        //let userAge = ["Age": age]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
           
            if let err = err {
                print("there was an err",err)
                return
            }
            let messageController = MessageController()
            let navcontroller = UINavigationController(rootViewController: messageController)
            self.present(navcontroller, animated: true)
        }
    }
    
    fileprivate func showHUDWithError(error: Error) {
        registeringHUD.dismiss()
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 3)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientLayer()
        
        setupLayout()
    }
    
    let goToRegisterBttn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Not a user, Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleGoToLogin() {
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
        
    }
    
    fileprivate func setupLayout () {
        navigationController?.isNavigationBarHidden = true
        
        
        let logoImage = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width/2, height: UIScreen.main.bounds.size.height/3))
        logoImage.image = #imageLiteral(resourceName: "Logo")
        logoImage.contentMode = .scaleAspectFit
        
        let overallStackView = UIStackView(arrangedSubviews: [logoImage, UIView(), Text, UIView(), FBLoginBttn, UIView(), LoginBttn])
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 30, bottom: 80, right: 30)
        overallStackView.spacing = 10
        
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
        
    }
    
    fileprivate func setupGradientLayer() {
        
        let topColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    
}
