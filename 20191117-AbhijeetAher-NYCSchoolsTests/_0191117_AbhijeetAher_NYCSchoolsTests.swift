//
//  _0191117_AbhijeetAher_NYCSchoolsTests.swift
//  20191117-AbhijeetAher-NYCSchoolsTests
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import XCTest
import CoreData
@testable import _0191117_AbhijeetAher_NYCSchools

class _0191117_AbhijeetAher_NYCSchoolsTests: XCTestCase {
    var sut: URLSession!

    override func setUp() {
        sut = URLSession(configuration: .default)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
       let school =  School(overview_paragraph: "overview paragraph", school_name: "Clinton School Writers & Artists, M.S. 260", website: "www.theclintonschool.net", dbn: "02M260")
        
        XCTAssertEqual(school.dbn, "02M260")
        XCTAssertEqual(school.school_name, "Clinton School Writers & Artists, M.S. 260")
        XCTAssertEqual(school.website, "www.theclintonschool.net")
        XCTAssertEqual(school.overview_paragraph, "overview paragraph")

        let schoolGradeModel = SchoolGrade(dbn: "02M260", school_name: "HENRY STREET SCHOOL FOR INTERNATIONAL STUDIES", num_of_sat_test_takers: "29", sat_critical_reading_avg_score: "355", sat_math_avg_score: "404", sat_writing_avg_score: "363")
        
        XCTAssertEqual(schoolGradeModel.dbn, "02M260")
        XCTAssertEqual(schoolGradeModel.school_name, "HENRY STREET SCHOOL FOR INTERNATIONAL STUDIES")
        XCTAssertEqual(schoolGradeModel.num_of_sat_test_takers, "29")
        XCTAssertEqual(schoolGradeModel.sat_critical_reading_avg_score, "355")
        XCTAssertEqual(schoolGradeModel.sat_math_avg_score, "404")
        XCTAssertEqual(schoolGradeModel.sat_writing_avg_score, "363")
        
        
        let urlSchools = CustomURL.createURL(withAPIPath: Constants.APIDetails.APIPathSchools    )
        XCTAssertEqual(urlSchools.absoluteString, "https://data.cityofnewyork.us/resource/s3k6-pzi2.json")

        let urlSchoolGrade = CustomURL.createURL(withAPIPath: Constants.APIDetails.APIPathSchoolsGrade    )
        XCTAssertEqual(urlSchoolGrade.absoluteString, "https://data.cityofnewyork.us/resource/f9bf-2cp4.json")

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    
    func testSchoolAPI(){
          // given
          let url =
            URL(string: "https://data.cityofnewyork.us/resource/s3k6-pzi2.json")
          let promise = expectation(description: "Completion handler invoked")
          var statusCode: Int?
          var responseError: Error?

          // when
          let dataTask = sut.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
          }
          dataTask.resume()
          wait(for: [promise], timeout: 5)

          // then
          XCTAssertNil(responseError)
          XCTAssertEqual(statusCode, 200)
        
    }
    
    func testSchoolScoreAPI(){
          // given
          let url =
            URL(string: "https://data.cityofnewyork.us/resource/f9bf-2cp4.json")
          let promise = expectation(description: "Completion handler invoked")
          var statusCode: Int?
          var responseError: Error?

          // when
          let dataTask = sut.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
          }
          dataTask.resume()
          wait(for: [promise], timeout: 5)

          // then
          XCTAssertNil(responseError)
          XCTAssertEqual(statusCode, 200)
        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
