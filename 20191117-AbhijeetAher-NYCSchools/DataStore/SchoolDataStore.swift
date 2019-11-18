//
//  SchoolDataStore.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol UIUpdaterProtocol: class {
    
    func updateUI()
}
class SchoolDataStore : NSObject{
    
    private weak var uiUpdater:UIUpdaterProtocol!

    let networkManager = NetworkDataManager.sharedNetworkmanager
    lazy var coreDataManager = CoreDataManager.sharedInstance
    let reachability = try! Reachability()
  
    init(uiUpdater: UIUpdaterProtocol){

           self.uiUpdater = uiUpdater
        super.init()

       }
    
    
    lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Schools.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "school_name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataManager.managedObjectContext, sectionNameKeyPath: #keyPath(Schools.school_name), cacheName: nil)
        return frc
    }()
    
    
    
    
    func fetchAllSchoolsData(completion:@escaping (_ data: Any?,_ status: Bool)->Void)->Void{
  
        reachability.whenReachable = { [weak self]_ in
            let urlStr = CustomURL.createURL(withAPIPath: Constants.APIDetails.APIPathSchools)
            let request = URLRequest(url: urlStr)
            
            self?.networkManager.fetchDataWithUrlRequest(request) {[weak self] (success, data ) in
            if success{
                print(data!)
                let jsonDecoder = JSONDecoder()
                do {
                    let responseModel = try jsonDecoder.decode([School].self, from: data!)
                    self?.saveDataWith(reponse: responseModel)
                    self?.uiUpdater?.updateUI()
                    completion(responseModel, true)
                } catch let error {
                    print(error.localizedDescription)
                    completion(nil, false)
                }
            }else{
                completion(nil, false)
            }
        }
            }

        reachability.whenUnreachable = { [weak self]_ in
            self?.uiUpdater?.updateUI()
        }
        
        do {
            try reachability.startNotifier()
            } catch {
            print("Unable to start notifier")
        }
    }
    
    
    
    
   
    func getDataFromDB(){
        do {
            try self.fetchedResultController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }

    
    private func createSchoolEntityFrom(responseModel: School) -> NSManagedObject?{
        // TODO: Do a guard check
        // iOS 10 and above
        let school = Schools(context: coreDataManager.managedObjectContext)
       
        school.school_name = responseModel.school_name
        school.overview_paragraph = responseModel.overview_paragraph
        school.website = responseModel.website
        school.dbn = responseModel.dbn

        return school
    }
    

    
    
    private func saveDataWith(reponse: [School]){
        
        deleteData()
        _ = reponse.map{self.createSchoolEntityFrom(responseModel: $0)}
        
        coreDataManager.saveContext()
        
    }
  func deleteData(){
             
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Schools")

             // Create Batch Delete Request
             let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

             do {
                 try coreDataManager.managedObjectContext.execute(batchDeleteRequest)

             } catch {
                 // Error Handling
             }

             
         }
      
    
}

extension SchoolDataStore:DataStoreProtocol{
    func sectionCount() -> Int {
        guard let sections = fetchedResultController.sections else { return 0 }
        return sections.count
    }
    
    func rowsCountIn(section: Int) -> Int {
        guard let sectionInfo = fetchedResultController.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    func itemAt(indexPath: IndexPath) -> Schools?{
        if let school = fetchedResultController.object(at: indexPath) as? Schools{
            return school
        }
        return nil
    }
    func titleForHeaderAt(section: Int) -> String{
        
        guard let sectionInfo = fetchedResultController.sections?[section] else { return "" }
        return sectionInfo.name
    }
    
}

