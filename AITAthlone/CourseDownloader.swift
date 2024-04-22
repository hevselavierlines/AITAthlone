//
//  CourseDownloader.swift
//  AITAthlone
//
//  Created by Manuel Baumgartner on 20/10/2015.
//  Copyright © 2015 Application Project Center. All rights reserved.
//

import Foundation
import Kanna

class CourseDownloader {
    var urlString : String
    var context : TimetableController
    init(_urlString: String, _context: TimetableController) {
        urlString = _urlString
        context = _context
    }
    /*
    self.context.timetable.addCourse(Course(_name: "Maths", _room: "V306", _prof: "Frank Doheny", _startTime: NSDate(timeIntervalSinceNow: 3600), _endTime: NSDate(timeIntervalSinceNow: 7200), _day: 2))
    self.context.tbCourses.reloadData()
    */
    /*
    dispatch_async(dispatch_get_main_queue()) {
    
    }
    */
    
    func run() {
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            /*
            let url = NSURL(string: self.urlString)
            let request = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
            }*/
            let url = NSURL(string: self.urlString)
            let request = NSMutableURLRequest(URL: url!)
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
            request.timeoutInterval = 10.0
            
            var response: NSURLResponse?
            var data : NSData = NSData()
            
            let courseTable = CourseTable()
            
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            } catch (let e) {
                print(e)
            }
            
            
            if let doc = Kanna.HTML(html: data, encoding: NSUTF8StringEncoding) {
                print(doc.title)
                
                var mainTable : XMLElement?
                
                for tables in doc.css("table") {
                    if(tables["border"] == "1") {
                        mainTable = tables
                    }
                }
                var row = mainTable?.css("tr").at(0)
                let cols = row?.css("td")
                var times = [String]()
                for var i = 0; i < cols?.count; i++ {
                    let col = cols?.at(i)
                    if(col?.text?.characters.count > 0) {
                        times.append(col!.text!)
                    }
                }
                var dayOfWeek = 0
                let rows = mainTable?.xpath("child::*")
                print(rows?.count)
                for var i = 1; i < rows?.count; i++ {
                    row = rows?.at(i)
                    let cells = row?.xpath("child::*")
                    /*Elements cells = rows.get(i).children();
                    int col = 0;
                    System.out.println(cells.get(0).text());
                    if(cells.get(0).text().length() == 3) {
                    dayOfWeek++;
                    
                    }*/
                    var col = 0
                    if cells?.at(0)?.text?.characters.count == 3 {
                        var fullDay = cells!.at(0)!.text!
                        if fullDay.lowercaseString == "mon" {
                            fullDay = "Monday"
                        } else if fullDay.lowercaseString == "tue" {
                            fullDay = "Tuesday"
                        } else if fullDay.lowercaseString == "wed" {
                            fullDay = "Wednesday"
                        } else if fullDay.lowercaseString == "thu" {
                            fullDay = "Thursday"
                        } else if fullDay.lowercaseString == "fri" {
                            fullDay = "Friday"
                        } else if fullDay.lowercaseString == "sat" {
                            fullDay = "Saturday"
                        } else if fullDay.lowercaseString == "sun" {
                            fullDay = "Sunday"
                        }
                        courseTable.addCourse(Course(_name: fullDay))
                        dayOfWeek++
                    }
                    for var j = 1; j < cells?.count; j++ {
                        let course = Course()
                        let cell = cells?.at(j)
                        let colspan = cell?["colspan"]
                        var spacing = 0
                        if colspan != nil {
                            let spac = Int(colspan!)
                            if spac != nil {
                                spacing = spac!
                            }
                        }
                        if spacing >= 1 {
                            if col < times.count {
                                course.setStartTime(times[col])
                            }
                            col += spacing
                            if col < times.count {
                                course.setEndTime(times[col])
                            } else {
                                course.setEndTime("18:00")
                            }
                            let elements = cell?.css("td")
                            if elements?.count >= 4 {
                                course.setName(elements!.at(0)!.text!)
                                course.setRoom(elements!.at(1)!.text!)
                                course.setProf(elements!.at(2)!.text!)
                            }
                            courseTable.addCourse(course)
                        } else {
                            col++
                        }
                    }
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.finished(courseTable)
            }
        }
        
    }
    
    func finished(_result : CourseTable) {
        context.update(_result)
    }
}
