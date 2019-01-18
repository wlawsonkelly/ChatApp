//
//  ProfileTopStackView.swift
//  ChatApp
//
//  Created by William Kelly on 1/17/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import UIKit

class ProfPageTopStackView: UIStackView {
    
    let homeButton = UIButton(type: .system)
    let iconLogo = UIImageView(image: #imageLiteral(resourceName: "Logo"))
    let messageButton = UIButton(type: .system)
    let restView = UIView()
    let moreView = UIView()
    let evenMoreView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        distribution = .fillEqually
        spacing = 0
        backgroundColor = #colorLiteral(red: 0.7607843137, green: 0.9294117647, blue: 0.6784313725, alpha: 1)
        restView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        moreView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        evenMoreView.backgroundColor = #colorLiteral(red: 1, green: 0.6749386191, blue: 0.7228371501, alpha: 1)
        //iconLogo.contentMode = .scaleAspectFill
        messageButton.setImage(#imageLiteral(resourceName: "MessagesIconCrusht").withRenderingMode(.alwaysOriginal), for: .normal)
        homeButton.setImage(#imageLiteral(resourceName: "SettingsBetter").withRenderingMode(.alwaysOriginal), for: .normal)
        
        [homeButton, moreView, iconLogo, evenMoreView, messageButton].forEach { (v) in
            addArrangedSubview(v)
        }
        
        //        let buttons = [#imageLiteral(resourceName: "CrushtHomIcon"), #imageLiteral(resourceName: "CrushTLogoIcon")].map{ (img) -> UIView in
        //            let button = UIButton(type: .system)
        //            button.setImage(img, for: .normal)
        //            return button
        ////        }
        //
        //        buttons.forEach { (v) in
        //            addArrangedSubview(v)
        //        }
        
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

