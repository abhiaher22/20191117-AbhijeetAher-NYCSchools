//
//  SchoolGrades+CoreDataProperties.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//
//

import Foundation
import CoreData


extension SchoolGrades {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SchoolGrades> {
        return NSFetchRequest<SchoolGrades>(entityName: "SchoolGrades")
    }

    @NSManaged public var dbn: String?
    @NSManaged public var num_of_sat_test_takers: String?
    @NSManaged public var sat_critical_reading_avg_score: String?
    @NSManaged public var sat_math_avg_score: String?
    @NSManaged public var sat_writing_avg_score: String?
    @NSManaged public var school_name: String?

}
