//
//  LogIndViewController.swift
//  POS-Tool
//
//  Created by Thomas Bjørk on 17/03/2016.
//  Copyright © 2016 Thomas Bjørk. All rights reserved.


import UIKit

class LogIndViewController: UIViewController, UITextFieldDelegate {

    //Constraints
    @IBOutlet var idTop: NSLayoutConstraint!
    
    @IBOutlet var userTop: NSLayoutConstraint!
    
    
    
    
    @IBOutlet var huskmigSwitch: UISwitch!
    @IBOutlet var txtID: UITextField!
    
    @IBOutlet var gemLoginSwitch: UISwitch!
    @IBOutlet var txtUsername: UITextField!
    
    @IBOutlet var txtPassword: UITextField!
    
    @IBAction func logInd(sender: AnyObject) {
        
        self.view.endEditing(true)
        idTop.constant = idConstant
        userTop.constant = userConstant
        UIView.animateWithDuration(0.3)
        {
            self.view.layoutIfNeeded()
        }
        checkLogin()
    }
    
    @IBOutlet var LogdIndButton: UIButton!
    var idConstant : CGFloat = 0
    var userConstant : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPassword.delegate = self
        
        idConstant = idTop.constant
        userConstant = userTop.constant
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogIndViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LogIndViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        //Add gesture recognizer
        var swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(LogIndViewController.swipedUp(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeUp)
        
        // Do any additional setup after loading the view.
    }
    
    func checkLogin()
    {
        LogdIndButton.hidden = true
        
        let keychain = Keychain()
        
        if(txtID.text != "" && txtUsername.text != "" && txtPassword.text != "")
        {
            
            let klientID = txtID.text
            let klientUsername = txtUsername.text
            let klientPassword = txtPassword.text //as! CFStringRef
            
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
                                if(self.gemLoginSwitch.on)
                                {
                                    
                                    NSUserDefaults.standardUserDefaults().setValue(true, forKey: "hasLoginKey")
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    
                                    keychain["id"] = klientID
                                    keychain["username"] = klientUsername
                                    keychain["password"] = klientPassword
                                    
                                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                                    self.performSegueWithIdentifier("butikInfo", sender: nil)
                                }
                                else
                                {
                                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(cookie)
                                    self.performSegueWithIdentifier("butikInfo", sender: nil)
                                }
                                
                            }
                            
                            
                        }
                        let alert = UIAlertController(title: "Forkert login", message: "En eller flere af dine brugeroplysninger er ikke korrekte. \nCheck dem og prøv igen"
                            , preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                            
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    
                }
            }
            task.resume()
        }
        else
        {
            //ALERT ACTION IKKE ALLE FELTER ER UDFYLDT!!
            let alert = UIAlertController(title: "Alle felter skal udfyldes", message: "Du har ikke udfyldt alle brugeroplysninger krævet til login. \nUdfyld alle felter og prøv igen"
                , preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
                
            }))
            
            self.presentViewController(alert, animated: true, completion: nil) //viser alert'en
        }
        
        LogdIndButton.hidden = false
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if(textField.returnKeyType == UIReturnKeyType.Go)
        {
            
            self.view.endEditing(true)
            idTop.constant = idConstant
            userTop.constant = userConstant
            UIView.animateWithDuration(0.3)
            {
                self.view.layoutIfNeeded()
            }
            checkLogin()
        }
        return true
    }
    
    func swipedUp(sender: NSNotificationCenter){
        view.endEditing(true)
    }
    func keyboardWillShow(sender: NSNotification) {
        idTop.constant = 0
        userTop.constant = 69
        UIView.animateWithDuration(0.3)
        {
            self.view.layoutIfNeeded()
        }
        
    }
    func keyboardWillHide(sender: NSNotification) {
        idTop.constant = idConstant
        userTop.constant = userConstant
        UIView.animateWithDuration(0.3)
        {
            self.view.layoutIfNeeded()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
