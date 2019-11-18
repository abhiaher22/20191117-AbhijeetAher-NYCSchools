//
//  CustomURL.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import Foundation

enum CustomURL{

    static func createURL(withAPIPath APIPath: String) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.APIDetails.APIScheme
    components.host   = Constants.APIDetails.APIHost
    components.path   = APIPath
    
    return components.url!
}
}
