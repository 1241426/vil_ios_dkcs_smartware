//
//  SettingsViewController.swift
//  Swift-Slide-Menu
//
//  Created by Philippe Boisney on 05/10/2015.
//  Copyright © 2015 Philippe Boisney. All rights reserved.
//

import UIKit

class SettingsViewController: ChildViewController {

    @IBAction func Logout(_ sender: AnyObject) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
        self.present(viewController, animated: true, completion: nil)
        SocketIOManager.sharedInstance.closeConnection()
        // Do any additional setup after loading the view.
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
