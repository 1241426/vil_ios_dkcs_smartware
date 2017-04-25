//
//  oCabinet.swift
//  Swift-Slide-Menu
//
//  Created by Hung on 12/26/16.
//  Copyright © 2016 Philippe Boisney. All rights reserved.
//

class oCabinet
{
    var CID: String = ""
    var CName: String = ""
    var CSerial: String = ""
    var Status = HomeViewController.Status_Cab.disConnected
    var StatusOld = HomeViewController.Status_Cab.disConnected
    
    var ListBranch: Array<oBranch> = Array()
    
    var TimeOn : oTime = oTime()
    var TimeOff : oTime = oTime()
    var ONOFF : Bool = false
    var ONOFFBranch : Bool = false
    var WanringBranch : Bool = false
    var GioHeThongTu:String = "---"
    
    var CS1: String = ""
    var CS2: String = ""
    var CS3: String = ""
}
