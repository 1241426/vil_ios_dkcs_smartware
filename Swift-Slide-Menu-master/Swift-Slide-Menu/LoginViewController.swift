//
//  LoginViewController.swift
//  Swift-Slide-Menu
//
//  Created by trilequoc91 on 1/3/17.
//  Copyright © 2017 Philippe Boisney. All rights reserved.
//

import UIKit
import Darwin
class LoginViewController: UIViewController {
    struct MyVariables {
        static var username:String=""
    }

    let LOGIN_URL = "android/googlemaps/kssc/adminlogin"
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func ExitApp(_ sender: AnyObject) {
        exit(0)
    }
    
    @IBAction func Login(_ sender: AnyObject) {
        
        let username = self.txtUsername.text
        MyVariables.username = self.txtUsername.text!
        let password = self.txtPassword.text
        
        if (username?.characters.count == 0) {
            UIAlertView(title: "Thông báo", message: "Vui lòng nhập tên đăng nhập", delegate: self, cancelButtonTitle: "OK").show()
            
        }
        else if (password?.characters.count == 0) {
            UIAlertView(title: "Thông báo", message: "Vui lòng nhập mật khẩu", delegate: self, cancelButtonTitle: "OK").show()
        }
        else {
            
            let URL: String = GlobalVariables.RestFul_URL + LOGIN_URL + "/" + username! + "/" + password!
            AsyncLogin(URL)

        }
    }
    
    func AsyncLogin(_ url: String) {
        let scriptUrl = url
        let myUrl = URL(string: scriptUrl);
        
        if (myUrl == nil) {
            UIAlertView(title: "Thông báo", message: "Đăng nhập thất bại! Vui lòng kiểm tra lại tài khoản", delegate: self, cancelButtonTitle: "OK").show()
            return
        }
        
        
        let session = URLSession.shared
        
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            do {
                let value = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if((value as AnyObject).intValue == 1) {
                    DispatchQueue.main.async {
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView")
                        self.present(viewController, animated: true, completion: nil)
                    }
                }
                else if((value as AnyObject).intValue == -1) {
                    DispatchQueue.main.async {
                        UIAlertView(title: "Thông báo", message: "Đăng nhập thất bại! Vui lòng kiểm tra lại tài khoản", delegate: self, cancelButtonTitle: "OK").show()
                    }
                }
                else {
                    DispatchQueue.main.async {
                        UIAlertView(title: "Thông báo", message: "Đăng nhập thất bại! Vui lòng kiểm tra lại tài khoản", delegate: self, cancelButtonTitle: "OK").show()
                    }
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        
        
    }    
}
