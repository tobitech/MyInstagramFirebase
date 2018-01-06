//
//  UserProfileController.swift
//  MyInstagramFirebase
//
//  Created by Tobi Omotayo on 06/01/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
    }
    
    fileprivate func fetchUser() {
        /// get the user based on the currently logged in user uid from firebase database
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            self.user = User(dictionary: dictionary)
            
            self.navigationItem.title = self.user?.username
            self.collectionView?.reloadData()
        }) { (err) in
            
            print("Failed to fetch user: ", err)
            
        }
    }
    
}


struct User {
    let username: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}






