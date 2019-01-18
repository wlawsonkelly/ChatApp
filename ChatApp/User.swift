//
//  User.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
    // defining our properties for our model layer
    var name: String?
    var age: Int?
    var school: String?
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    var bio: String?
    
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    
    var toId: String?
    var fromId: String?
    
    init(dictionary: [String: Any]) {
        //initialize our user stuff
        
        //let age = dictionary["Age"] as? Int
        self.name = dictionary["Full Name"] as? String ?? ""
        self.age = dictionary["Age"] as? Int
        self.school = dictionary["School"] as? String ?? ""
        self.imageUrl1 = dictionary["ImageUrl1"] as? String
        self.imageUrl2 = dictionary["ImageUrl2"] as? String
        self.imageUrl3 = dictionary["ImageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.bio = dictionary["Bio"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
        self.toId = dictionary["toCrush"] as? String ?? ""
        self.fromId = dictionary["fromCrush"] as? String ?? ""
        
    }

    

}
