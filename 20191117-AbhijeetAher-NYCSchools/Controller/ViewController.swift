//
//  ViewController.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIUpdaterProtocol {
    // Add data again
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // data store
    private var schoolDataStore:SchoolDataStore!
    
    //SchoolGrade array property declared in second view controller to pass the data
    private var schoolGradeForSVC = [SchoolGrade]()

    // data store
    private let schoolGrade = SchoolGradeDataStore()

    // table view
    @IBOutlet weak var schoolTableView:UITableView!
  
    // MARK: - UIUpdaterProtocol
    // UIUpdaterProtocol method. This is called when data needs to be displayed on table view
    func updateUI() {
        schoolDataStore.getDataFromDB()
        if schoolDataStore.sectionCount() == 0{
             Alert.display(withTitle: "Alert", withMessage: "No data found. Please enable the internet connection.", onViewController: self)
        }
        else{
            DispatchQueue.main.async {
            self.schoolTableView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.schoolTableView.reloadData()
        }
        }
    }
    
    
    // MARK: - View Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // data store initialization and delegate
        schoolDataStore = SchoolDataStore(uiUpdater: self)
       // schoolDataStore.fetchedResultController.delegate = self
        
        // start activity indicator
        activityIndicator.startAnimating()
      
        
        // API call to fetch the schools data. Data will be fetched online if network connection is available else will be fetched from the offline data store.
        // There is a room for improvement how this calls can be managed but for simplicity I am calling one after another
        // Also if for the first time internet connection is offline and user is trying to fetch the data, an error will display. This feature can be improved by continuosly monitoring an internet connection and if successful should make service call
        fetchSchoolsData()
        
         // API call to fetch the schools grads data. Data will be fetched online if network connection is available else will be fetched from the offline data store.

       fetchSchoolsGradeData()
  
    }
    
       
    // MARK: - func to fetch data

    func fetchSchoolsData(){
        schoolDataStore.fetchAllSchoolsData { (data, isSucess) in
                  
              DispatchQueue.main.async {
                  if isSucess{
                    print("Schools data stored sucessfully")
                  }
                  else{
                      Alert.display(withTitle: "Alert", withMessage: "Error while loading the data. Please try again!", onViewController: self)
                      }
                  }
              }
    }

    func fetchSchoolsGradeData(){
        schoolGrade.fetchSchoolGrades { (data, isSucess) in
            
            if isSucess{
                print("School grades stored sucessfully")
            }
            else{
                print("Error fetching Scholl greades")
            }
        }
    }
    
    // MARK: - segue  SchoolGradeViewController
    // passing the SchoolGrade object to next controller

    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
               
               if let destination = segue.destination as? SchoolGradeViewController{
                   destination.arraySchoolGrade = schoolGradeForSVC
               }
           }
}


// MARK: - UITableViewDelegate, UITableViewDelegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return schoolDataStore.sectionCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return schoolDataStore.rowsCountIn(section: section)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolCell", for: indexPath)
        if let item = schoolDataStore.itemAt(indexPath: indexPath) {
            cell.textLabel?.text = item.school_name
            cell.detailTextLabel?.text = item.overview_paragraph
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)

         let item = schoolDataStore.itemAt(indexPath: indexPath)
        
        schoolGrade.fetchSchoolGradeData(forSchoolWithDBN: item!.dbn!) { (schoolGrade ,isSucess) in
            if isSucess{
                schoolGradeForSVC = schoolGrade!
                performSegue(withIdentifier: "SchoolGradeViewController", sender: Any?.self)
            }
                else {
                Alert.display(withTitle: "Alert", withMessage: "No record found!", onViewController: self)
                print("No school grades record found!!")
            }
        }
    }
}


