//
//  UserProfileHeader.swift
//  MyInstagramFirebase
//
//  Created by Tobi Omotayo on 06/01/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
            setupProfileImage()
        }
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
        
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func setupProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        guard let url = URL(string: profileImageUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let err = error {
                print("Failed to fetch profile image: ", err)
            }
            
            guard let data = data else { return }
            
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
            
            }.resume()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
