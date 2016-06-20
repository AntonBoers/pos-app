//
//  ViewController.swift
//  Butikker
//
//  Created by Thomas Bjørk on 30/09/15.
//  Copyright (c) 2015 Thomas Bjørk. All rights reserved.
//

import UIKit
import SwiftyJSON
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var omsaetningTotal: UILabel!
    @IBOutlet var antalTotal: UILabel!

    var json : JSON = []
    var jsonExist = false
    var array : [String] = []
    var objects = [[String: String]]()
    
    var antalTotalInt: Int = 0
    var antalTotalIntString = ""
    var omsætningTotalFloat: Float = 0
    
    var butikToken = ""
    
    var refreshControl:UIRefreshControl!
    
    var arrayID : [Int] = []
    
    @IBOutlet var logUdButton: UIButton!
    
    @IBAction func logdUdAction(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(false, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let cookieJar = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in cookieJar.cookies! as [NSHTTPCookie]
        {
            cookieJar.deleteCookie(cookie)
        }
        
        let keychain = Keychain()
        keychain["id"] = nil
        keychain["username"] = nil
        keychain["password"] = nil
        
        performSegueWithIdentifier("message", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        //Styrer pull to refresh og hvad for en method den skal calles
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        getJSON()
    }
    
    override func viewDidAppear(animated: Bool) {
     
        //getJSON()
    }
    
    
    
    func getJSON(){

        let url:NSURL = NSURL(string: "https://www.eadministration.dk/tokenlokation.asp")!
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

            self.json = JSON(data: data!)
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { //Kører en task i background thread
                self.parseJSON(self.json, number: 3) //Bliver kaldt i background thread
                dispatch_async(dispatch_get_main_queue()) { //Main queue til UI updates
                    self.tableView.reloadData()
                    
                    self.antalTotal.text! = ""
                    self.omsaetningTotal.text! = ""
                    
                    self.antalTotal.text! += String("Antal bonner total: "  + String(self.antalTotalInt))
                    self.omsaetningTotal.text! += String("Omsætning total: "  + String(self.omsætningTotalFloat))
                    
                }
            }
        }
        task.resume()
        

        
    }
    
    func refresh(){
        //refresh funktion. Den bliver kaldt fra 'pull to refresh'
        //Den resetter de to variabler til nul, siden at de indenholder de tidligere values inden refresh og skal nulstilles til de nye values
        self.antalTotalInt = 0
        self.omsætningTotalFloat = 0
        getJSON() //Kalder getJSON() for at få ny information fra JSON og opdatere UI med nyt information
        
        
        
        self.refreshControl.endRefreshing()
    }
    func parseJSON(json: JSON, number: Int) {
        var arrayAntal : [Int] = [] //Indenholder alle antal fra JSON variablen 'Antal'
        var arrayOmsaetning : [String] = [] //Indenholder alle omsætnings values fra JSON

        for result in json[].arrayValue {
            arrayAntal.append(result["Antal"].intValue) //Looper gennem JSON og adder alle 'antal' over i arrayet
            arrayOmsaetning.append(result["Oms"].stringValue) //Looper gennem JSON og adder alle 'Omsætning' over i arrayet
            arrayID.append(result["ID"].intValue)
            
        }
        
        for var i = 0; i < arrayAntal.count; i++ {
            antalTotalInt += arrayAntal[i] //Regner den totale antal ud ved at plusse alle total values fra arrayet
        }
        
        for var i = 0; i < arrayOmsaetning.count; i++ {
            let omsaetning = (arrayOmsaetning[i] as NSString).floatValue //Laver string arrayets value om til float value og plusser den for at finde totale omsætning
            omsætningTotalFloat += omsaetning
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "GoButik")
        {
            let nextViewController = (segue.destinationViewController as! ViewControllerButikInfo)
            let selectedRow = tableView.indexPathForSelectedRow?.row
            let indexPath = sender as! NSIndexPath
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
            
            nextViewController.navn = cell.titel.text!
            nextViewController.budget = cell.budget.text!
            nextViewController.omsaetning = cell.omsætning.text!
            nextViewController.antal = cell.antal.text!
            nextViewController.omsaetningb = cell.omsbon.text!
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return json.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        
        print("BUTIK: " + cell.titel.text!)
        
        /*
        
        let nextViewController = ViewControllerButikInfo()
        //nextViewController.navn = cell.titel.text!
        print(nextViewController.navn + " burde vaere OK")
        nextViewController.budget = cell.budget.text!
        nextViewController.omsaetning = "good"
        nextViewController.antal = cell.antal.text!
        nextViewController.id = arrayID[indexPath.row]
        */
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("GoButik", sender: indexPath)
        
        
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
        
        //Populater data fra JSON ind i variabler
        let Oms = json[row]["Oms"]
        let Lokation = json[row]["Lokation"]
        let beskrivelse = json[row]["Beskrivelse"]
        let antal = json[row]["Antal"]
        
        //Omsætning pr bon
        let omsFloat = Float((json[row]["Oms"].stringValue).stringByReplacingOccurrencesOfString(",", withString: "."))
        let antalFloat = Float((json[row]["Antal"].stringValue).stringByReplacingOccurrencesOfString(",", withString: "."))
        
        let gennemsnitBon : Float32 = (omsFloat! / antalFloat!)
        cell.omsbon.text = String(gennemsnitBon)
        
        //Populater cellernes labels med information fra JSON såsom omsætning, antal bonner osv
        cell.titel.text = String(Lokation) + ": " + String(beskrivelse)
        cell.budget.text = "INTET"
        cell.omsætning.text = String(Oms)
        cell.antal.text = String(antal)
        
        
        
        
        if((NSUserDefaults.standardUserDefaults().boolForKey("ios8+")))
        {
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
        }
        
        return cell
    }

}

