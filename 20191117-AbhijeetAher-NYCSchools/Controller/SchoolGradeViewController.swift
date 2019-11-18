//
//  SchoolGradeViewController.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import UIKit

import UIKit

class SchoolGradeViewController: UIViewController {

    // SchoolGrade object passed from previous controller
     var arraySchoolGrade = [SchoolGrade]()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SchoolGradeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arraySchoolGrade.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySchoolGrade.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GradeCell", for: indexPath)
        let schoolGradeModel = arraySchoolGrade[indexPath.row]
        cell.textLabel?.text = schoolGradeModel.school_name
     
        // This can be improved by creating a custom table view cell
        cell.detailTextLabel?.text = "SAT test takers: \(String(describing: schoolGradeModel.num_of_sat_test_takers!)) \nAverage reading score: \(String(describing: schoolGradeModel.sat_critical_reading_avg_score!)) \nAverage math score: \(String(describing: schoolGradeModel.sat_math_avg_score!)) \nAverage writing score: \(String(describing: schoolGradeModel.sat_writing_avg_score!))"

        return cell
    }
}
