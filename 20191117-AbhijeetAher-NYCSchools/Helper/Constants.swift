//
//  Constants.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import Foundation
struct Constants {

    struct APIDetails {

        internal enum APIHOST: String {
           case DEV = "data.cityofnewyork.us"
        }
        static let APIScheme = "https"
        static let APIHost = APIHOST.DEV.rawValue
        static let APIPathSchools = "/resource/s3k6-pzi2.json"
        static let APIPathSchoolsGrade = "/resource/f9bf-2cp4.json"
    }
}


extension String {

    var stripped: String? {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}
