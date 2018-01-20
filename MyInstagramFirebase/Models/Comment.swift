//
//  Comment.swift
//  MyInstagramFirebase
//
//  Created by Tobi Omotayo on 20/01/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
