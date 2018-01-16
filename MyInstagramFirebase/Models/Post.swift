//
//  Post.swift
//  MyInstagramFirebase
//
//  Created by Tobi Omotayo on 12/01/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import Foundation

struct Post {
    
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
    
}
