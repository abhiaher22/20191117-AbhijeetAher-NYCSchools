//
//  SchoolGrade.swift
//  JSONtoCoreData
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import Foundation
import CoreData
struct SchoolGrade : Decodable {
    var dbn : String?
    var school_name : String?
    var num_of_sat_test_takers : String?
    var sat_critical_reading_avg_score : String?
    var sat_math_avg_score : String?
    var sat_writing_avg_score : String?
    
}
