//
//  ViewControllerButikInfo.swift
//  Butikker
//
//  Created by Thomas Bjørk on 16/11/2015.
//  Copyright © 2015 Thomas Bjørk. All rights reserved.
//

import UIKit
var testVar = ""
class ViewControllerButikInfo: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet var butikNavn: UINavigationItem!
    @IBOutlet var budgetLabel: UILabel!
    var id = 0
    @IBOutlet var butik: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var omsaetningLabel: UILabel!
    @IBOutlet var omsaetningTLabel: UILabel!
    @IBOutlet var omsaetningMAlabel: UILabel!
    @IBOutlet var omsaetningbon: UILabel!
    @IBOutlet var retursalgLabel: UILabel!
    @IBOutlet var antalbonner: UILabel!
    var navn = ""
    var budget = ""
    var omsaetning = ""
    var antal = ""
    var omsaetningb = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        butik.text = navn
        print("NAVN: " + navn)
        
        let date = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.stringFromDate(date)

        let url:NSURL = NSURL(string: "https://www.eadministration.dk/tokenappstat.asp?lokation=" + String(id) + "&dato=" + dateString)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "GET"
        
        var cookieToSend : NSHTTPCookie!
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies
        for cookie in cookies! {
            var cookieProperties = [String: AnyObject]()
            cookieProperties[NSHTTPCookieName] = cookie.name
            cookieProperties[NSHTTPCookieValue] = cookie.value
            
            
            if(cookie.name == "esession" && cookie.value != "")
            {
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                cookieToSend = cookie
            }
            
        }
        
        request.setValue(cookieToSend.value, forHTTPHeaderField: "Set-Cookie")
        
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            let json = JSON(data: data!)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { //Kører en task i background thread
                
                dispatch_async(dispatch_get_main_queue()) { //Main queue til UI updates
                    self.omsaetningTLabel.text = self.omsaetningTLabel.text! + " " + String(json.array![json.count - 1][3])
                    self.antalbonner.text = self.antalbonner.text! + " " + self.antal
                    self.retursalgLabel.text = self.retursalgLabel.text! + " " + "få det.."
 
                }
            }
            
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        
        //Fylder cellerne
        let row = indexPath.row
        
        // Lige rækker
        if((row % 2) == 0){
            cell.backgroundColor = UIColor.whiteColor()
            
            // Ulige rækker
        } else {
            cell.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        }
        
        
        
        
        
        if((NSUserDefaults.standardUserDefaults().boolForKey("ios8+")))
        {
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
        }
        
        return cell
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
