//
//  SchoolGradeDataStore.swift
//  JSONtoCoreData
//
//  Created by Abhijeet Aher on 11/17/19.
//

import Foundation
import CoreData

class SchoolGradeDataStore{
    
    // core data
    lazy var coreDataManager = CoreDataManager.sharedInstance
    
    // object repsonsible for fetching the api data
    let networkManager = NetworkDataManager.sharedNetworkmanager

    
    func fetchSchoolGrades(completion:@escaping (_ data: Any?,_ status: Bool)->Void)->Void{
        let url = CustomURL.createURL(withAPIPath: Constants.APIDetails.APIPathSchoolsGrade)
              let request = URLRequest(url: url)
              networkManager.fetchDataWithUrlRequest(request) {[weak self] (success, data) in
                  if success{
                      let jsonDecoder = JSONDecoder()
                      do {
                          let responseModel = try jsonDecoder.decode([SchoolGrade].self, from: data!)
                          self?.saveGradesDataWith(reponse: responseModel)
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
    
    
       private func createURL(withAPIPath APIPath: String) -> URL {
              
              var components = URLComponents()
              components.scheme = Constants.APIDetails.APIScheme
              components.host   = Constants.APIDetails.APIHost
              components.path   = APIPath
              
              return components.url!
          }
    
    private func createEntityFromSchoolGrade(responseModel: SchoolGrade) -> NSManagedObject?{
         // TODO: Do a guard check
        let schoolGrade = SchoolGrades(context: coreDataManager.managedObjectContext)
        schoolGrade.dbn = responseModel.dbn
        schoolGrade.school_name = responseModel.school_name
        schoolGrade.num_of_sat_test_takers = responseModel.num_of_sat_test_takers
        schoolGrade.sat_critical_reading_avg_score = responseModel.sat_critical_reading_avg_score
        schoolGrade.sat_math_avg_score = responseModel.sat_math_avg_score
        schoolGrade.sat_writing_avg_score = responseModel.sat_writing_avg_score
        return schoolGrade
     }
    
    private func saveGradesDataWith(reponse: [SchoolGrade]){
           
           deleteData()
           _ = reponse.map{self.createEntityFromSchoolGrade(responseModel: $0)}
           
           coreDataManager.saveContext()
           
       }
      
      func deleteData(){
             
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SchoolGrades")

             // Create Batch Delete Request
             let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
             do {
                 try coreDataManager.managedObjectContext.execute(batchDeleteRequest)

             } catch {
                 // Error Handling
             }

         }
    
    // Fetch the school grades data when clicked on table view cell
    func fetchSchoolGradeData(forSchoolWithDBN DBN: String, completion: (_ data :  [SchoolGrade]?, _ status : Bool) -> Void )
    {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SchoolGrades")
    request.predicate = NSPredicate(format: "dbn = %@", DBN)
    request.returnsObjectsAsFaults = false
    do {
        let result = try coreDataManager.managedObjectContext.fetch(request)
        var arrayschoolGrade = [SchoolGrade]()

        for data in result as! [NSManagedObject] {
            let schoolGradeModel = SchoolGrade(dbn: (data.value(forKey: "dbn") as! String), school_name:  (data.value(forKey: "school_name") as! String), num_of_sat_test_takers: (data.value(forKey: "num_of_sat_test_takers") as! String), sat_critical_reading_avg_score: (data.value(forKey: "sat_critical_reading_avg_score") as! String), sat_math_avg_score: (data.value(forKey: "sat_math_avg_score") as! String), sat_writing_avg_score: (data.value(forKey: "sat_writing_avg_score") as! String))
            arrayschoolGrade.append(schoolGradeModel)
      }
        completion(arrayschoolGrade, true)

        
    } catch {
        completion(nil, false)

        print("Failed")
    }
      
    }
}
