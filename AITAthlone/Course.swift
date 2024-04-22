//
//  Course.swift
//  AITAthlone
//
//  Created by Manuel Baumgartner on 13/10/2015.
//  Copyright (c) 2015 Application Project Center. All rights reserved.
//

import Foundation

class Course {
    private var name : String
    private var professor : String?
    private var startTime : NSDate?
    private var endTime : NSDate?
    private var day : Int?
    private var room : String?
    private var justDay : Bool
    
    init() {
        name = ""
        professor = ""
        startTime = NSDate(timeIntervalSinceNow: 0)
        endTime = NSDate(timeIntervalSinceNow: 3600)
        day = 0
        justDay = false
    }
    
    init(_name : String, _room : String, _prof : String, _startTime : NSDate, _endTime : NSDate, _day : Int) {
        name = _name
        professor = _prof
        startTime = _startTime
        endTime = _endTime
        day = _day
        justDay = false
        room = _room
    }
    
    init(_name : String) {
        name = _name
        justDay = true
    }
    
    func isDay() -> Bool {
        return justDay
    }
    
    func getName() -> String {
        return name
    }
    
    func getProfessor() -> String {
        if(professor != nil) {
            return professor!
        } else {
            return ""
        }
    }
    
    func getRoom() -> String {
        if(room != nil) {
            return room!
        } else {
            return ""
        }
    }
    
    func getStartTime() -> NSDate {
        if(startTime != nil) {
            return startTime!
        } else {
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    func getEndTime() -> NSDate {
        if(endTime != nil) {
            return endTime!
        } else {
            return NSDate(timeIntervalSince1970: 3600)
        }
    }
    
    func getDay() -> Int {
        if(day != nil) {
            return day!
        } else {
            return 0
        }
    }
    
    func parseTime(_time : String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.dateFromString(_time)
        if(date != nil) {
            return date!
        } else {
            return NSDate(timeIntervalSince1970: 0)
        }
    }
    
    func stringTime(_date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let string = dateFormatter.stringFromDate(_date)
        return string
    }
    
    func setStartTime(_time : String) {
        startTime = parseTime(_time)
    }
    
    func setEndTime(_time : String) {
        endTime = parseTime(_time)
    }
    
    func setProf(_prof : String) {
        professor = _prof
    }
    
    func setRoom(_room : String) {
        room = _room
    }
    
    func setName(_name : String) {
        name = _name
    }
    
    func setDay(_day : Int) {
        day = _day
    }
    
    func serialize() -> NSDictionary {
        var dict : NSDictionary?
        if justDay {
            dict = ["name":name, "justday":true]
        } else {
            dict = ["name":name, "room":room!, "prof":professor!, "starttime":stringTime(startTime!), "endtime":stringTime(endTime!), "justday":false]
        }
        
        return dict!
    }
    
    init(_dict : NSDictionary) {
        name = _dict["name"] as! String
        justDay = _dict["justday"] as! Bool
        if !justDay {
            room = _dict["room"] as! String?
            professor = _dict["prof"] as! String?
            startTime = parseTime(_dict["starttime"] as! String)
            endTime = parseTime(_dict["endtime"] as! String)
        }
    }
}
