//
//  Image.swift
//  MindValley
//
//  Created by Kelvin Tan on 7/25/18.
//  Copyright © 2018 Kelvin Tan. All rights reserved.
//

import Foundation
import Alamofire



class Image {
    private var _imageLink: String!
    
    var imageLink: String {
        if _imageLink == nil {
            _imageLink = ""
        }
        return _imageLink
    }
    
    init(imageLink: String){
        self._imageLink = imageLink
    }
    
    
}
