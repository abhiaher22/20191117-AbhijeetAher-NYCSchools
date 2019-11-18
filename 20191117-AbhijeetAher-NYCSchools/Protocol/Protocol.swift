//
//  Protocol.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import Foundation
protocol DataStoreProtocol {

    associatedtype T
    func sectionCount() -> Int
    func rowsCountIn(section: Int) -> Int
    func itemAt(indexPath: IndexPath) -> T?
}
