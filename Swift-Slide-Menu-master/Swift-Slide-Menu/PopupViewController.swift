//
//  PopupViewController.swift
//  Swift-Slide-Menu
//
//  Created by Hung on 12/22/16.
//  Copyright © 2016 Philippe Boisney. All rights reserved.
//

import Foundation
import UIKit
class PopupViewController: UIViewController {
    
    @IBOutlet weak var btnTat: UIButton!
    @IBOutlet weak var btnBat: UIButton!
    @IBOutlet weak var txtTrangThai: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var btnReadStatus: UIButton!
    var cab: oCabinet = oCabinet()
    
    @IBAction func Bat(_ sender: AnyObject) {
           }
    @IBAction func Close(_ sender: AnyObject) {
        
        RemoveAnimate()
    }
    func BindingCab(_ cab:oCabinet)
    {
        self.cab = cab
        txtName.text = cab.CName
    }
    func ShowAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 1.0
        self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func RemoveAnimate() {
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 0.0
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            },completion: {
                (finished:Bool) in if(finished){ self.view.removeFromSuperview()}
        })
    }
    override func viewDidLoad() {
             super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
//        print("=============\(cab.CName as? String)")
//        txtName.text = cab.CName as? String
        txtTrangThai.lineBreakMode = NSLineBreakMode.byWordWrapping
        txtTrangThai.numberOfLines = 3
        txtTrangThai.text = (cab.Status == HomeViewController.Status_Cab.connected) ? "Tủ kết nối-Đèn tắt" : (cab.Status == HomeViewController.Status_Cab.disConnected) ? "Tủ kết nối-Đèn sáng" : "Tủ mất kết nối"
        btnBat.layer.cornerRadius = 7
        btnTat.layer.cornerRadius = 7
        if let image = UIImage(named: "settings") {
            btnReadStatus.setImage(image, for: UIControlState())
        }
        ShowAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
