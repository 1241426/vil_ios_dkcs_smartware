//
//  ViewController.swift
//  Swift-Slide-Menu
//
//  Created by Philippe Boisney on 05/10/2015.
//  Copyright © 2015 Philippe Boisney. All rights reserved.
//

import UIKit

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        addChildView("HomeScreenID", titleOfChildren: "Bản đồ", iconName: "home")
        addChildView("ContactScreenID", titleOfChildren: "Dạng cây", iconName: "contact")
        addChildView("LoveScreenID", titleOfChildren: "Lịch sử sự cố", iconName: "love")
        addChildView("SettingsScreenID", titleOfChildren: "Đăng xuất", iconName: "settings")
        
        
        //Show the first childScreen
        showFirstChild()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

