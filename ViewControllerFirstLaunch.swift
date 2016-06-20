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

    @IBOutlet var loading: UIActivityIndicatorView!
    @IBAction func Indstillinger(sender: AnyObject) {
        performSegueWithIdentifier("login", sender: self )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(animated: Bool) {
        textBody.text = "Log ind med dine loginoplysninger fra POS-TOOL, så kan du live følge med i omsætningen i din butik. \nHar du brug for hjælp med til login, så kontakt vores support på 3524 0110"
        checkForToken()
    }
    
    func openSettings() {
       //åbner Settings
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        
    }
    
    func checkForToken() {
        let keychain = Keychain()
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        
        if(hasLoginKey == true)
        {
            loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            loading.color = UIColor.blackColor()
            loading.hidden = false
            loading.startAnimating()
            indstillingerButton.hidden = true
            
            let klientID = keychain["id"]
            let klientUsername = keychain["username"]
            let klientPassword = keychain["password"]
            
            let url:NSURL = NSURL(string: "https://www.eadministration.dk/logonapp.asp")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            
            request.HTTPMethod = "POST"
            
            
            let test = NSString(format: "klient=%@&bruger=%@&kodeord=%@", klientID!, klientUsername!, klientPassword!)
            
            
            let encoded: NSData = test.dataUsingEncoding(NSUTF8StringEncoding)!
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("https://www.eadministration.dk/login/", forHTTPHeaderField: "Referer")
            request.setValue("https://www.eadministration.dk", forHTTPHeaderField: "Origin")
            request.HTTPBody = encoded
            
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                
                if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String: String]
                {
                    let feedback = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    
                    if((feedback?.containsString("OK")) != nil)
                    {
                        let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                        NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
                        
                        for cookie in cookies {
                            var cookieProperties = [String: AnyObject]()
                            cookieProperties[NSHTTPCookieName] = cookie.name
                            cookieProperties[NSHTTPCookieValue] = cookie.value
                            
                            
                            if(cookie.name == "esession" && cookie.value != "")
                            {
                                
                                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                                self.performSegueWithIdentifier("automaticLogin", sender: nil)
                                
                            }
                            
                            
                            
                            
                            
                            
                        }
                    }
                    else
                    {
                        self.indstillingerButton.hidden = false
                        
                    }
                    
                    self.loading.stopAnimating()
                    self.loading.hidden = true
                }
            }
            task.resume()
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
