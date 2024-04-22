//
//  CourseTable.swift
//  AITAthlone
//
//  Created by Manuel Baumgartner on 13/10/2015.
//  Copyright (c) 2015 Application Project Center. All rights reserved.
//

import Foundation

class CourseTable {
    var courses = [Course]()
    
    func addCourse(_course : Course) {
        courses.append(_course)
    }
    
    func getCourses(_day : Int) -> [Course] {
        return courses
    }
    
    func getCourse(_pos : Int) -> Course {
        return courses[_pos]
    }
    
    func count() -> Int {
        return courses.count
    }
    
    func serialize() -> NSData {
        var serials = [NSDictionary](count: courses.count, repeatedValue: NSDictionary())
        for var i = 0; i < courses.count; i++ {
            serials[i] = courses[i].serialize()
        }
        let data = try? NSJSONSerialization.dataWithJSONObject(serials, options: NSJSONWritingOptions())
        return data!
    }
    
    func deserialize(_json : NSData) {
        courses.removeAll(keepCapacity: true)
        let obj = (try! NSJSONSerialization.JSONObjectWithData(_json, options: NSJSONReadingOptions())) as! NSArray
        
        for var i = 0; i < obj.count; i++ {
            let dict = obj[i] as! NSDictionary
            
            courses.append(Course(_dict: dict))
        }
    }
    
    func save() {
        let fileManager = NSFileManager.defaultManager()
        let filePath = "\(CourseTable.documentsDirectory())/coursetable.af"
        
        fileManager.createFileAtPath(filePath, contents: serialize(), attributes: nil)
    }
    
    func load() {
        let fileManager = NSFileManager.defaultManager()
        let filePath = "\(CourseTable.documentsDirectory())/coursetable.af"
        if fileManager.fileExistsAtPath(filePath) {
            let data = NSData(contentsOfFile: filePath)
            deserialize(data!)
        } else {
            //No file found, a new one has to be created.
            print("nofile")
        }
    }
    
    static func documentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0]
        return documentDirectory
    }
}
