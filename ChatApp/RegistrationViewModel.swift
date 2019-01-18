//
//  RegistrationViewModel.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    var school: String? { didSet { checkFormValidity() } }
    
    var age: Int? { didSet {checkFormValidity() }}
    
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else {return}
        bindableIsRegistering.value = true
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            
            if let err = err {
                print(err)
                completion(err)
                return
            }
            
            print("Successfully registered user:", res?.user.uid ?? "")
            
            self.saveImageToFirebase(completion: completion)
            
        }
    }
    
    func performFBLogin (completion: @escaping (Error?) -> ()) {
        
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) ->()) {
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: {(_, err) in
            if let err = err {
                completion(err)
                return //bail
            }
            print("finished Uploading image")
            ref.downloadURL(completion: { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download url of our image is:", url?.absoluteString ?? "")
                
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) ->()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData: [String: Any] =
            ["Full Name": fullName ?? "",
             "uid": uid,
             "School": school ?? "",
             "Age": age ?? 18,
             "Bio": "",
             "minSeekingAge": 18,
             "maxSeekingAge": 50,
             "ImageUrl1": imageUrl]
        //let userAge = ["Age": age]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            self.bindableIsRegistering.value = false
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && school?.isEmpty == false && "\(age ?? -1)".isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
        
    }
    
}
