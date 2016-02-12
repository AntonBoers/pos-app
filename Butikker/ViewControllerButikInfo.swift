//
//  ViewControllerButikInfo.swift
//  Butikker
//
//  Created by Thomas Bjørk on 16/11/2015.
//  Copyright © 2015 Thomas Bjørk. All rights reserved.
//

import UIKit
var testVar = ""
class ViewControllerButikInfo: UIViewController {

    @IBOutlet var butikNavn: UINavigationItem!
    var navn = ""
    var budget = ""
    var omsaetning = ""
    var antal = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        butikNavn.title = navn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
