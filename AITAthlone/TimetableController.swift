//
//  FirstViewController.swift
//  AITAthlone
//
//  Created by Manuel Baumgartner on 06/10/2015.
//  Copyright (c) 2015 Application Project Center. All rights reserved.
//

import UIKit

class TimetableController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tbCourses: UITableView!
    var refreshControl:UIRefreshControl!
    var timetable = CourseTable()
    var downloader : CourseDownloader?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
        [[UITabBar appearance] setTintColor:[UIColor grayColor]]; // for unselected items that are gray
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor greenColor]];
*/
        
        UITabBar.appearance().tintColor = UIColor.greenColor()
        UITabBar.appearance().selectedImageTintColor = UIColor.whiteColor()
        
        tbCourses.estimatedRowHeight = 50
        tbCourses.rowHeight = UITableViewAutomaticDimension
        /*timetable.addCourse(Course(_name: "Monday"))
        timetable.addCourse(Course(_name: "Mobile Computing", _room: "Y202", _prof: "Michael", _startTime: NSDate(timeIntervalSinceNow: 0), _endTime: NSDate(timeIntervalSinceNow: 3600), _day: 1))
        
        timetable.addCourse(Course(_name: "Tuesday"))
        timetable.addCourse(Course(_name: "Maths", _room: "V306", _prof: "Frank Doheny", _startTime: NSDate(timeIntervalSinceNow: 3600), _endTime: NSDate(timeIntervalSinceNow: 7200), _day: 2))*/
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tbCourses.addSubview(refreshControl)
        
        timetable.load()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if getAppDelegate().needRefresh {
            loadFromWebsite()
        }
    }
    
    func loadFromWebsite() {
        let courseId = getAppDelegate().loadCourse()//"%23SPLUSD8398F"
        let url = "http://timetable.ait.ie/reporting/individual;student+set;id;"+courseId+"?t=student+set+individual&days=1-5&weeks=&periods=1-20&template=student+set+individual"
        print(url)
        downloader = CourseDownloader(_urlString: url, _context: self)
        downloader?.run()
        refreshControl.beginRefreshing()
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func refresh(sender : AnyObject) {
        loadFromWebsite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timetable.count()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(timetable.getCourse(indexPath.item).isDay()) {
            return 30.0
        } else {
            if timetable.getCourse(indexPath.item).getName().characters.count > 30 {
                return 70.0
            } else {
                return 50.0
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let course = timetable.getCourse(indexPath.item)
        if course.isDay() {
            let cell = tableView.dequeueReusableCellWithIdentifier("tvHead", forIndexPath: indexPath) 
            let tvDay = cell.contentView.viewWithTag(10) as! UILabel
            tvDay.text = course.getName()
            return cell
        } else {
            let dateFomatter = NSDateFormatter()
            dateFomatter.dateFormat = "HH:mm"
            
            let cell = tableView.dequeueReusableCellWithIdentifier("tvTime", forIndexPath: indexPath) 
            let tvCourse = cell.contentView.viewWithTag(10) as! UILabel
            let tvRoom = cell.contentView.viewWithTag(20) as! UILabel
            let tvStart = cell.contentView.viewWithTag(30) as! UILabel
            let tvEnd = cell.contentView.viewWithTag(40) as! UILabel
            
            tvCourse.text = course.getName()
            tvRoom.text = course.getRoom()
            tvStart.text = dateFomatter.stringFromDate(course.getStartTime())
            tvEnd.text = dateFomatter.stringFromDate(course.getEndTime())
            return cell
        }
    }
    
    func update(_timetable : CourseTable) {
        if _timetable.count() > 0 {
            timetable = CourseTable()
            tbCourses.reloadData()
            timetable = _timetable
            var indexPaths = [NSIndexPath](count: timetable.count(), repeatedValue: NSIndexPath())
            for var i = 0; i < timetable.count(); i++ {
                indexPaths[i] = NSIndexPath(forRow: i, inSection: 0)
            }
            tbCourses.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
            if timetable.count() > 0 {
                timetable.save()
            }
            getAppDelegate().needRefresh = false
        }
        refreshControl.endRefreshing()
    }
}

