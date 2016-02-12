//
//  ViewControllerFirstLaunch.swift
//  Butikker
//
//  Created by Thomas Bjørk on 04/11/2015.
//  Copyright © 2015 Thomas Bjørk. All rights reserved.
//

import UIKit

class ViewControllerFirstLaunch: UIViewController {

    @IBOutlet var GåTilOmsætning: UIButton!
    @IBOutlet var textBody: UILabel!
    @IBOutlet var textTitel: UILabel!
    @IBOutlet var indstillingerButton: UIButton!

    @IBAction func Indstillinger(sender: AnyObject) {
        
        openSettings()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForToken", name: UIApplicationWillEnterForegroundNotification, object: nil) //Kalder funktionen 'checkForToken' efter app'en returner fra foreground
    }
    
    func openSettings() {
       //åbner Settings
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        
    }
    
    func checkForToken() {
        //Checker at token area ikke er tomt og at token ikke er et empty string: hvis ja, ændre UI
        if(NSUserDefaults.standardUserDefaults().objectForKey("butik_token") != nil)
        {
            if(NSUserDefaults.standardUserDefaults().valueForKey("butik_token") as! NSString != "")
            {
                indstillingerButton.hidden = true
                GåTilOmsætning.hidden = false
                textBody.hidden = true
                textTitel.text = "Du kan nu gå videre og se din omsætning!"
            }
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
