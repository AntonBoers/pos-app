//
//  ViewController.swift
//  Butikker
//
//  Created by Thomas Bjørk on 30/09/15.
//  Copyright (c) 2015 Thomas Bjørk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var omsaetningTotal: UILabel!
    @IBOutlet var antalTotal: UILabel!
    //var data = NSMutableData()
    var json : JSON = []
    var jsonExist = false
    var array : [String] = []
    var objects = [[String: String]]()
    
    var antalTotalInt: Int = 0
    var antalTotalIntString = ""
    var omsætningTotalFloat: Float = 0
    
    var butikToken = ""
    
    var refreshControl:UIRefreshControl!
    
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
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForToken", name: UIApplicationWillEnterForegroundNotification, object: nil) //Caller funktionen 'checkForToken' når appen kommer i foreground
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("butik_token") != nil)
        {
            if(NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! NSString != "")
            {
                //trimmer token
                butikToken = NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! String
                butikToken = butikToken.stringByReplacingOccurrencesOfString(" ", withString: "")
                butikToken = butikToken.stringByReplacingOccurrencesOfString("{", withString: "")
                butikToken = butikToken.stringByReplacingOccurrencesOfString("}", withString: "")
            }
        }
        
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") && butikToken != "")
        {
            //Kalder getJSON
            getJSON()

        }
        else
        {
            //first launch
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            performSegueWithIdentifier("message", sender: self)
            
        }
    }
    
    func checkForToken() //Denne funktion bliver kun kaldt efter at appen returner til foreground!!
    {
        //checker om der har været nogen æmdringer i token, trimmer osv
        if(NSUserDefaults.standardUserDefaults().objectForKey("butik_token") != nil)
        {
            if(NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! NSString != "")
            {
                butikToken = NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! String
                butikToken = butikToken.stringByReplacingOccurrencesOfString(" ", withString: "")
                butikToken = butikToken.stringByReplacingOccurrencesOfString("{", withString: "")
                butikToken = butikToken.stringByReplacingOccurrencesOfString("}", withString: "")
            }
        }
        getJSON()
    }
    
    func getJSON(){
        let urlString = "http://www.eadministration.dk/tokenlokation.asp?token=%7b" + butikToken + "%7d"  //JSON url
        if let url = NSURL(string: urlString){ //checker at URL er valid
            if let data = try? NSData(contentsOfURL: url, options: []) { //checker hvis det er muligt at få JSON fra url'en. Hvis det ikke er, så er token invalid og if(json[0].. bliver kaldt og sikre sig, at der intet JSON information er blevet hentet. Den vil derefter displaye en alert box der forklare at token er invalid og tvinger brugeren ind i Indstillinger
                json = JSON(data: data)
                tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine //Separator line = true
            }
            else{
                json = []
                tableView.separatorStyle = UITableViewCellSeparatorStyle.None //Separator line = false
                print("token ikke valid")
                let alert = UIAlertController(title: "Forkert token", message: "Den token du har indtastet under Indstillinger matcher ikke noget i vores database\n Gå ind i Indstillinger og sikre dig, at du har skrevet den korrekt"
                    , preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Gå Til Indstillinger", style: UIAlertActionStyle.Default, handler: { action in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }))
                
                presentViewController(alert, animated: true, completion: nil) //viser alert'en
            }
        }
        
        
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
        /* Koden til 'vis Mere' funktion - checker bare efter segue identifier
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
        }
        */
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
        /* Koden til 'vis Mere' funktion
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCell
        
        print("BUTIK: " + cell.titel.text!)
        
        let nextViewController = ViewControllerButikInfo()
        nextViewController.navn = cell.titel.text!
        print(nextViewController.navn + " burde vaere OK")
        nextViewController.budget = cell.budget.text!
        nextViewController.omsaetning = cell.omsætning.text!
        nextViewController.antal = cell.antal.text!
        
        performSegueWithIdentifier("GoButik", sender: indexPath)
        */
        
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TableViewCell
        //Fylder cellerne
        let row = indexPath.row
        
        if((row % 2) == 0){ //Hvert row som er et lige tal har hvid baggrund
            cell.backgroundColor = UIColor.whiteColor()
        }
        else{ //hvert row som er et 'un-even' tal har svag toning af grå
            cell.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        }
        
        //Populater data fra JSON ind i variabler
        let Oms = json[row]["Oms"]
        let Lokation = json[row]["Lokation"]
        let beskrivelse = json[row]["Beskrivelse"]
        let antal = json[row]["Antal"]
        
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

