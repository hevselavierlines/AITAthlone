//
//  SettingsController.swift
//  AITAthlone
//
//  Created by Manuel Baumgartner on 25/10/2015.
//  Copyright © 2015 Application Project Center. All rights reserved.
//

import UIKit

class SettingsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, NSXMLParserDelegate, UISearchBarDelegate {
    
    class CourseFinder {
        var key : String?
        var name : String?
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    var selected = "%23SPLUSD8398F"
    @IBOutlet weak var tfCourse: UITextField!
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let str = searchText.lowercaseString
        filteredCourses.removeAll(keepCapacity: true)
        var animated = false
        if str.characters.count > 2 {
            for var i = 0; i < courses.count; i++ {
                if courses[i].name!.lowercaseString.containsString(str) {
                    filteredCourses.append(courses[i])
                }
            }
            if filteredCourses.count > 0 {
                selected = filteredCourses[0].key!
                animated = true
            }
        }
        pvCourse.reloadAllComponents()
        let row = searchCourse(selected)
        if row >= 0 {
            pvCourse.selectRow(row, inComponent: 0, animated: animated)
        }
    }
    @IBOutlet weak var pvCourse: UIPickerView!
    var mode = 0
    var courses = [CourseFinder]()
    var filteredCourses = [CourseFinder]()
    var courseKeys = [String]()
    var courseValues = [String]()
    var openedElement = "root"
    var rootElement : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        let urlpath = NSBundle.mainBundle().pathForResource("CourseList", ofType: "xml")
        let url = NSURL.fileURLWithPath(urlpath!)
        let parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
        
        
        selected = getAppDelegate().loadCourse()
        
        let pos = searchCourse(selected)
        print(pos)
        if pos >= 0 {
            pvCourse.selectRow(pos, inComponent: 0, animated: true)
        }
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if rootElement == nil {
            rootElement = elementName
        }
        if elementName == "string-array" {
            let name = attributeDict["name"]
            if name == "course_keys" {
                mode = 1
            } else if name == "course_value" {
                mode = 2
            }
            openedElement = "string-array"
        } else if elementName == "item" {
            openedElement = "item"
        } else {
            openedElement = "root"
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if openedElement == "item" {
            if mode == 1 {
                courseKeys.append(string)
            } else if mode == 2 {
                courseValues.append(string)
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == rootElement! {
            for var i = 0; i < courseKeys.count; i++ {
                let course = CourseFinder()
                course.key = courseKeys[i]
                course.name = courseValues[i]
                courses.append(course)
            }
        } else {
            openedElement = "jassne"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if filteredCourses.count > 0 {
            return filteredCourses.count
        } else {
            return courseValues.count
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func searchCourse(_course : String) -> Int {
        var ret = -1
        var cs = courses
        if filteredCourses.count > 0 {
            cs = filteredCourses
        }
        for var i = 0; i < cs.count && ret < 0; i++ {
            if cs[i].key! == _course {
                ret = i
            }
        }
        return ret
    }
    
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return UIFont.systemFontOfSize(UIFont.systemFontSize()).lineHeight * 2 * UIScreen.mainScreen().scale
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var label : UILabel?
        if view == nil {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: UIFont.systemFontOfSize(UIFont.systemFontSize()).lineHeight * 3 * UIScreen.mainScreen().scale))
            label?.textAlignment = NSTextAlignment.Center
            label?.numberOfLines = 3
            label?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            label?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        } else {
            label = view as? UILabel
        }
        if filteredCourses.count > 0 {
            label?.text = filteredCourses[row].name
        } else {
            label?.text = courses[row].name
        }
        return label!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if filteredCourses.count > 0 {
            selected = filteredCourses[row].key!
        } else {
            selected = courses[row].key!
        }
        getAppDelegate().saveCourse(selected)
        getAppDelegate().needRefresh = true
        
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
