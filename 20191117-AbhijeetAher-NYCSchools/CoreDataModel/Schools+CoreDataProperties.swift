//
//  Schools+CoreDataProperties.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//
//

import Foundation
import CoreData


extension Schools {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schools> {
        return NSFetchRequest<Schools>(entityName: "Schools")
    }

    @NSManaged public var dbn: String?
    @NSManaged public var overview_paragraph: String?
    @NSManaged public var school_name: String?
    @NSManaged public var url: String?
    @NSManaged public var website: String?

}
