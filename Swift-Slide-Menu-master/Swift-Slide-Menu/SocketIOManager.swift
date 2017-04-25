//
//  SocketIOManager.swift
//  Swift-Slide-Menu
//
//  Created by Hung on 12/23/16.
//  Copyright © 2016 Philippe Boisney. All rights reserved.
//

import SocketIO
import UserNotifications
import UserNotificationsUI
class SocketIOManager: NSObject , UNUserNotificationCenterDelegate{
    static let sharedInstance = SocketIOManager()
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    let socket = SocketIOClient(socketURL: URL(string: "http://112.213.95.102:1505")!, config: [.log(false), .forcePolling(true)])
    var ArrTemp: Array<oCabinet> = Array()
    
    override init() {
        super.init()
        
        socket.on("android_msgpush") { dataArray, ack in
            if let dsSocket_Msg = dataArray as? [[String: AnyObject]] {
                for msg in dsSocket_Msg {
                    
                    let name = msg["name"] as? String
                    let type = msg["type"] as? String
                    let res = msg["res"] as? String
                    let value = msg["value"] as? String
                    let Serial = msg["panelID"] as? String
                    
                    //                   self.CallNotification("aaaaaaaaaaaaaaaaaaaaaaa")
                    if(name == "t_tuketnoi")
                    {
                        if(type == "1")
                        {
                            let index = HomeViewController.MyVariables.ListCabinet.index{$0.CSerial == Serial}
                            if(index != nil)
                            {
                                let cab = HomeViewController.MyVariables.ListCabinet[index!] as? oCabinet
                                
                                if(cab != nil)
                                {
                                    if(value == "1")
                                    {
                                        cab?.Status = HomeViewController.Status_Cab.connected
                                        
                                    }
                                    else if(value == "2")
                                    {
                                        cab?.Status = HomeViewController.Status_Cab.connected_DS
                                    }
                                    else
                                    {
                                        cab?.Status = HomeViewController.Status_Cab.disConnected
                                    }
                                    if(cab?.StatusOld != cab?.Status)
                                    {
                                        cab?.StatusOld = (cab?.Status)!
                                        HomeViewController.UpdateIconCabOnMap(index!)
                                    }
                                    
                                }
                                
                                
                            }
                        }
                    }
                    else if(name == "t_trangthainhanh")
                    {
                        if(type == "1")
                        {
                            if(res == "2" || res == "1")
                            {
                                if(value! == "-1") {continue}
                                let values = value!.components(separatedBy: "-")
                                
                                if(values.count == 2)
                                {
                                    let index = HomeViewController.MyVariables.ListCabinet.index{$0.CSerial == Serial}
                                    if(index != nil)
                                    {
                                        let cab = HomeViewController.MyVariables.ListCabinet[index!] as? oCabinet
                                        if(cab != nil)
                                        {
                                            if(Int(values[0])! > (cab?.ListBranch.count)! )
                                            {
                                                print("LOIIIIIIIIIIII " + (cab?.CName)! + " nhánh: " + value!)
                                                continue
                                                
                                            }
                                            cab?.ListBranch[Int(values[0])! - 1].Status = Int(values[1])! == 1 ? HomeViewController.Status_Branch.on : HomeViewController.Status_Branch.off
                                            
                                            
                                            
                                            
                                            print( "socket tra ve - " +  (cab?.CName)! + " nhánh: " + value!)
                                            if(cab?.ONOFFBranch)!
                                            {
                                                var hour : Int = 0
                                                var minutes : Int = 0
                                                var seconds : Int = 0
                                                let date = Date()
                                                let calendar = Calendar.current
                                                if(cab?.GioHeThongTu == "---")
                                                {
                                                    hour = calendar.component(.hour, from: date)
                                                    minutes = calendar.component(.minute, from: date)
                                                    seconds = calendar.component(.second, from: date) + hour * 3600 + minutes * 60
                                                    
                                                }
                                                else
                                                {
                                                    let kq = cab?.GioHeThongTu.components(separatedBy: ":")
                                                    
                                                    if(kq?.count == 3)
                                                    {
                                                        hour = Int((kq?[0])!)!
                                                        minutes = Int((kq?[1])!)!
                                                        seconds = Int((kq?[2])!)! + hour * 3600 + minutes * 60
                                                    }
                                                }
                                                let kq1 : Bool = self.CheckTimeScheduleOfCab(cab: cab! , branch: Int(values[0])! - 1 ,seconds: seconds)
                                                
                                                if(kq1)//nhanh dang trong khung gio bat
                                                {
                                                    if(cab?.ListBranch[Int(values[0])! - 1].Status == HomeViewController.Status_Branch.off)
                                                    {
                                                        if(self.CheckTimeForCS(secondCurrent: seconds, secondOn: (cab?.ListBranch[Int(values[0])! - 1].TimeOn.second)!))
                                                        {
                                                            
                                                            let mess = (cab?.CName)! + " - Nhánh "+String(Int(values[0])!)+" có thể đang TẮT trong khung giờ BẬT"
                                                            
                                                            
                                                            let msgNoti : oMsgNotification = oMsgNotification()
                                                            msgNoti.Serial = (cab?.CSerial)!
                                                            msgNoti.Loai = "NHANH"
                                                            msgNoti.ChiSo = Int(values[0])!
                                                            msgNoti.ThoiGian = seconds
                                                            msgNoti.Msg = mess
                                                            msgNoti.sThoiGian = String(hour) + ":" + String(minutes)
                                                            let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                                                            if(bflag){
                                                                self.CallNotification(mess)
                                                            }
                                                            else
                                                            { print("---------da ton tai notification " + (cab?.CName)!)}
                                                        }
                                                    }
                                                }
                                                else//nhanh dang trong khung gio tat
                                                {
                                                    if(cab?.ListBranch[Int(values[0])! - 1].Status == HomeViewController.Status_Branch.on)
                                                    {
                                                        if(self.CheckTimeForBranch(secondCurrent: seconds, secondOn: (cab?.ListBranch[Int(values[0])! - 1].TimeOn.second)!))
                                                        {
                                                            let mess = (cab?.CName)! + " - Nhánh "+String(Int(values[0])!)+" có thể đang BẬT trong khung giờ TẮT"
                                                            let msgNoti : oMsgNotification = oMsgNotification()
                                                            msgNoti.Serial = (cab?.CSerial)!
                                                            msgNoti.Loai = "NHANH"
                                                            msgNoti.ChiSo = Int(values[0])!
                                                            msgNoti.ThoiGian = seconds
                                                            msgNoti.Msg = mess
                                                            msgNoti.sThoiGian = String(hour) + ":" + String(minutes)
                                                            let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                                                            if(bflag){
                                                                self.CallNotification(mess)
                                                            }
                                                            else
                                                            {
                                                                print("---------da ton tai notification " + (cab?.CName)!)
                                                            }
                                                        }
                                                       
                                                        
                                                        
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                    else if(name == "t_thoigianhethongtu")
                    {
                        if(type != "1") {continue}
                        
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_GIOHETHONGTU")
                                
                                if(index > 0)
                                {
                                    let maxValue = HomeViewController.MyVariables.ListWarning[index].Value_Max as Int
                                    let minValue = HomeViewController.MyVariables.ListWarning[index].Value_Min as Int
                                    
                                    let dateFormatter = DateFormatter()
                                    let dateFormatter1 = DateFormatter()
                                    dateFormatter.dateFormat = "HH:mm:ss zzz"
                                    dateFormatter1.dateFormat = "HH:mm:ss"
                                    //Parse gio cua Tu
                                    
                                    let gio = self.ParseTime(value!)
                                    if(gio == "-1") {
                                        print(msg)
                                        continue
                                    }
                                    
                                    let zone = " UTC"
                                    
                                    
                                    let gioTu = gio + zone
                                    let dateTu = dateFormatter.date(from: gioTu)!
                                    
                                    //Parse gio he thong
                                    
                                    let date = Date()
                                    let giohethong = dateFormatter1.string(from: date) + zone
                                    
                                    let dateHeThong = dateFormatter.date(from: giohethong)!
                                    let cab = self.GetCabBySerial(Serial!)
                                    if(cab.CID == ""){ continue }
                                    
                                    var hour : Int = 0
                                    var minutes : Int = 0
                                    var seconds : Int = 0
                                    
                                    let calendar = Calendar.current
                                    cab.GioHeThongTu = gio
                                    if(cab.GioHeThongTu == "---")
                                    {
                                        hour = calendar.component(.hour, from: date)
                                        minutes = calendar.component(.minute, from: date)
                                        seconds = calendar.component(.second, from: date) + hour * 3600 + minutes * 60
                                        
                                    }
                                    else
                                    {
                                        let kq = cab.GioHeThongTu.components(separatedBy: ":")
                                        
                                        if(kq.count == 3)
                                        {
                                            hour = Int((kq[0]))!
                                            minutes = Int((kq[1]))!
                                            seconds = Int((kq[2]))! + hour * 3600 + minutes * 60
                                        }
                                    }
                                    
                                    //print("gio hien tai : " + String(hour) + ":" + String(minutes))
                                    // Comparing time.
                                    if (dateTu as NSDate).earlierDate(dateHeThong) == dateTu {
                                        if dateTu == dateHeThong {
                                            //print("Same time")
                                        }
                                        else {
                                            //gio hien tai lon hon gio tu
                                            
                                            let diff = dateHeThong.timeIntervalSince(dateTu)
                                            
                                            
                                            let minutes = Int(diff / 60);
                                            if(minutes > minValue)
                                            {
                                                let mess : String = cab.CName + " " + gio + " :giờ tủ chạy chậm hơn giờ hệ thống"
                                                //tu chay cham
                                                
                                                
                                                let msgNoti : oMsgNotification = oMsgNotification()
                                                msgNoti.Serial = (cab.CSerial)
                                                msgNoti.Loai = "THOIGIAN"
                                                msgNoti.ChiSo = -1
                                                msgNoti.ThoiGian = seconds
                                                msgNoti.Msg = mess
                                                msgNoti.sThoiGian = String(hour) + ":" + String(minutes)
                                                let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                                                if(bflag){
                                                    self.CallNotification(mess)
                                                }
                                                
                                            }
                                            
                                            
                                            
                                        }
                                    }
                                    else {
                                        //gio hien tai nho hon gio tu
                                        
                                        
                                        let diff = dateTu.timeIntervalSince(dateHeThong)
                                        let minutes = Int(diff / 60);
                                        if(minutes > maxValue)
                                        {
                                            let mess : String = cab.CName + " " + gio + " :giờ tủ chạy nhanh hơn giờ hệ thống"
                                            //tu chay nhanh
                                            
                                            let msgNoti : oMsgNotification = oMsgNotification()
                                            msgNoti.Serial = (cab.CSerial)
                                            msgNoti.Loai = "THOIGIAN"
                                            msgNoti.ChiSo = -1
                                            msgNoti.ThoiGian = seconds
                                            msgNoti.Msg = mess
                                            msgNoti.sThoiGian = String(hour) + ":" + String(minutes)
                                            let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                                            if(bflag){
                                                self.CallNotification(mess)
                                            }
                                            
                                        }
                                                                            }
                                }
                            }
                        }
                        
                    }
                        //Canh báo Dong
                    else if(name == "t_dong1")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_DONG1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_dong", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_dong2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_DONG2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_dong", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_dong3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_DONG3")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_dong", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                        //Canh báo Áp
                    else if(name == "t_ap1")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_AP1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_ap", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_ap2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_AP2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_ap", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_ap3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_AP3")
                                
                                if(index != -1)
                                {
                                    print("----- " + res!)
                                    print(msg)
                                    self.ProcessInfoCabExtracted("t_ap", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                        //tan so
                    else if(name == "t_tanso1")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_TANSO1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_tanso", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_tanso2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_TANSO2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_tanso", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_tanso3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_TANSO3")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_tanso", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                        //cong suat thuc
                    else if(name == "t_congsuatthuc1")
                    {
                        if(type != "1") {continue}
                        if(res == "2"  || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSTHUC1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_csthuc", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_congsuatthuc2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSTHUC2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_csthuc", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_congsuatthuc3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSTHUC3")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_csthuc", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                        //cong suat bieu kien
                    else if(name == "t_congsuatbieukien1")
                    {
                        if(type != "1") {continue}
                        if(res == "2"  || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSBIEUKIEN1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_csbieukien", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_congsuatbieukien2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSBIEUKIEN2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_csbieukien", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_congsuatbieukien3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSBIEUKIEN3")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_csbieukien", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                        //he so cong suat
                    else if(name == "t_hesocongsuat1")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_HESOCS1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_hesocs", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_hesocongsuat2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_HESOCS2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_hesocs", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_hesocongsuat3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_HESOCS3")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_hesocs", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                        //cong suat khang
                    else if(name == "t_congsuatkhang1")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSKHANG1")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_cskhang", Serial: Serial!, value: value!, index: "1")
                                }
                            }
                        }
                    }
                    else if(name == "t_congsuatkhang2")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSKHANG2")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_cskhang", Serial: Serial!, value: value!, index: "2")
                                }
                            }
                        }
                    }
                    else if(name == "t_congsuatkhang3")
                    {
                        if(type != "1") {continue}
                        if(res == "2" || res == "1")
                        {
                            if(HomeViewController.MyVariables.ListWarning.count > 0)
                            {
                                let index = self.GetIndexInWarningList("T_CSKHANG3")
                                
                                if(index != -1)
                                {
                                    self.ProcessInfoCabExtracted("t_cskhang", Serial: Serial!, value: value!, index: "3")
                                }
                            }
                        }
                    }
                    //print(msg)
                }
            }
        }
        
    }
    func CheckTimeForBranch(secondCurrent : Int , secondOn : Int) -> Bool
    {
        let diff = secondOn - secondCurrent
        if(abs(diff) < HomeViewController.MyVariables.MinuteLimit * 60)
        {
            return false
        }
        return true
    }
    func CheckTimeForCS(secondCurrent : Int , secondOn : Int) -> Bool
    {
        let diff = secondCurrent - secondOn
        if(abs(diff) < HomeViewController.MyVariables.MinuteLimit * 60)
        {
            return false
        }
        return true
    }
    func CheckAvaibleMsgNotification(msg : oMsgNotification) -> Bool {
        if(HomeViewController.MyVariables.ListMsgNotificion.count == 0)
        {
            HomeViewController.MyVariables.ListMsgNotificion.append(msg)
            return true
        }
        for i in 0...HomeViewController.MyVariables.ListMsgNotificion.count - 1
        {
            let noti = HomeViewController.MyVariables.ListMsgNotificion[i]
            if(noti.Loai != msg.Loai) { continue}
            if(msg.Loai != "THOIGIAN")
            {
                if(noti.Msg == msg.Msg && noti.Serial == msg.Serial)
                {
                    if(msg.ThoiGian - noti.ThoiGian >= (HomeViewController.MyVariables.MinuteOfMsg * 60))
                    {
                        print(String(noti.ThoiGian) + " -> " + String(msg.ThoiGian))
                        noti.ThoiGian = msg.ThoiGian
                        noti.sThoiGian = msg.sThoiGian
                        return true
                    }
                    else
                    {
                        return false
                    }
                    
                }
            }
            else
            {
                if(noti.Serial == msg.Serial)
                {
                    if(msg.ThoiGian - noti.ThoiGian >= (HomeViewController.MyVariables.MinuteOfMsg * 60))
                    {
                        noti.ThoiGian = msg.ThoiGian
                        noti.sThoiGian = msg.sThoiGian
                        return true
                    }
                    else
                    {
                        return false
                    }
                    
                }
            }
            
        }
        
        HomeViewController.MyVariables.ListMsgNotificion.append(msg)
        return true
    }
    func ReadKWPhase(Serial : String)
    {
        for i in 1...3
        {
            let scriptUrl = "http://112.213.95.102:1501/panel/read_kw_phase/" + Serial + "/" + String(i)  + "/1"
            
            let myUrl = URL(string: scriptUrl);
            
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
                
                
            }
            
            task.resume()
            sleep(1)
        }
    }
    
    func ParseTime(_ time: String) -> String {
        if(time == "-1") { return "-1" }
        var t = time.components(separatedBy: "_")
        if (t.count < 3)
        {
            
            t = [String]()
            t[0] = "00"
            t[1] = "00"
            t[2] = "00"
        }
        else
        {
            if (Int(t[0])! > 24)
            {
                t[0] = "00"
            }
            if (Int(t[1])! > 60)
            {
                t[1] = "00"
            }
            if (Int(t[2])! > 60)
            {
                t[2] = "00"
            }
        }
        // Dinh dang 2 chu so
        if (Int(t[0])! < 10)
        {
            t[0] = "0" +  t[0]
        }
        if (Int(t[1])! < 10)
        {
            t[1] = "0" + t[1]
        }
        if (Int(t[2])! < 10)
        {
            t[2] = "0" + t[2]
        }
        return (t[0] + ":" + t[1] + ":" + t[2])
    }
    func GetCabBySerial(_ Serial : String) -> oCabinet {
        let index = HomeViewController.MyVariables.ListCabinet.index{$0.CSerial == Serial}
        if(index != nil)
        {
            let cab = HomeViewController.MyVariables.ListCabinet[index!] as? oCabinet
            return cab!
            
        }
        return oCabinet()
    }
    func GetIndexInWarningList (_ name:String) -> Int{
        if(HomeViewController.MyVariables.ListWarning.count == 0) {return -1}
        for i in 0...HomeViewController.MyVariables.ListWarning.count - 1
        {
            let warning = HomeViewController.MyVariables.ListWarning[i] as? oWarning
            if(warning?.mKey == name)
            {
                return i
            }
        }
        return -1
        
    }
    var dem:Int = 0
    func CallNotification(_ mess:String){
        //        let notification = UILocalNotification()
        //        notification.alertAction = "Go back to App"
        //        notification.alertBody = mess
        //        notification.fireDate = Date(timeIntervalSinceNow: 1)
        //        notification.soundName = UILocalNotificationDefaultSoundName
        //        UIApplication.shared.scheduleLocalNotification(notification)
        
        
        print("message show notification: " + mess)
        if(mess == "") {return}
        if #available(iOS 10.0, *) {
            dem += 1
            let content = UNMutableNotificationContent()
            content.title = ""
            content.body = mess
            content.sound = UNNotificationSound.default()
            
            //To Present image in notification
            if let path = Bundle.main.path(forResource: "monkey", ofType: "png") {
                let url = URL(fileURLWithPath: path)
                
                do {
                    
                    let attachment = try UNNotificationAttachment(identifier: String(dem), url: url, options: nil)
                    content.attachments = [attachment]
                } catch {
                    print("attachment not found.")
                }
            }
            
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
            let request = UNNotificationRequest(identifier: String(dem), content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request){(error) in
                
                if (error != nil){
                    
                    print(error?.localizedDescription)
                }
            }
            
        } else {
            // Fallback on earlier versions
            let notification = UILocalNotification()
            notification.alertAction = "Go back to App"
            notification.alertBody = mess
            notification.fireDate = Date(timeIntervalSinceNow: 1)
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
        }
        
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    func ProcessInfoCabExtracted(_ name : String,Serial : String,value : String,index : String){
        
        //get current time
        let date = Date()
        let calendar = Calendar.current
        
        
        var hour : Int = 0
        var minutes : Int = 0
        var seconds : Int = 0
        
        
        
        
        let cab = self.GetCabBySerial(Serial)
        
        if(value  == "-1" || cab.CID == "")
        {
            return
        }
        if(cab.GioHeThongTu == "---")
        {
            hour = calendar.component(.hour, from: date)
            minutes = calendar.component(.minute, from: date)
            seconds = calendar.component(.second, from: date) + hour * 3600 + minutes * 60
        }
        else
        {
            let values = cab.GioHeThongTu.components(separatedBy: ":")
            
            if(values.count == 3)
            {
                hour = Int(values[0])!
                minutes = Int(values[1])!
                seconds = Int(values[2])! + hour * 3600 + minutes * 60
            }
        }
        
        var mess:String=""
        var canhbao:Bool = false
        let msgNoti : oMsgNotification = oMsgNotification()
        msgNoti.Serial = (cab.CSerial)
        msgNoti.Loai = "THONGSOTU"
        msgNoti.ChiSo = Int(index)!
        msgNoti.ThoiGian = seconds
        msgNoti.sThoiGian = String(hour) + ":" + String(minutes)
        if(name == "t_ap" || name == "t_tanso" || name == "t_hesocs" )
        {
            
            if(name == "t_ap")
            {
                if(Double(value) == 0)
                {
                    mess = cab.CName + " Áp "+index+" : "+value+" = 0"
                    
                    msgNoti.Msg = mess
                    
                    let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                    if(bflag){
                        self.CallNotification(mess)
                    }
                    
                    
                }
            }
            else if(name == "t_tanso")
            {
                if(Double(value) == 0)
                {
                    mess = cab.CName + " Tần số "+index+" : "+value+" = 0"
                    msgNoti.Msg = mess
                    
                    let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                    if(bflag){
                        self.CallNotification(mess)
                    }
                    
                }
            }
                
            else if(name == "t_hesocs")
            {
                if(Double(value) == 0)
                {
                    mess = cab.CName + " Hệ số CS "+index+" : "+value+" = 0"
                    msgNoti.Msg = mess
                    
                    let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                    if(bflag){
                        self.CallNotification(mess)
                    }
                    
                }
            }
            
        }
            
        else
        {
            
            
            if(cab.ONOFFBranch)
            {
                
                let ListTimeResult : Array<oTime> = GetTime(cab: cab)
                let timeon = ListTimeResult[0]
                let timeoff = ListTimeResult[1]
                //                print ("timeon : " + String(timeon.hour) + ":" + String(timeon.minute))
                //                print ("timeoff : " + String(timeoff.hour) + ":" + String(timeoff.minute))
                let kq : Bool = self.CheckTimeSchedule(timeON: timeon, timeOFF: timeoff, second: seconds )
                if(kq)//nhanh dang trong khung gio bat
                {
                    if(Double(value) == 0)
                    {
                        if(self.CheckTimeForCS(secondCurrent: seconds, secondOn: timeon.second))
                        {
                            if(name == "t_dong")
                            {
                                mess = cab.CName + " - Dòng "+index+" = 0 => Cảnh báo tủ có thể có đèn tắt"
                            
                            }
                            else if(name == "t_csthuc")
                            {
                                mess = cab.CName + " - Công suất thực "+index+" = 0 => Cảnh báo tủ có thể có đèn tắt"
                            }
                            else if(name == "t_congsuatbieukien")
                            {
                                mess = cab.CName + " - Công suất biểu kiến "+index+" = 0 => Cảnh báo tủ có thể có đèn tắt"
                            }
                            else if(name == "t_cskhang")
                            {
                                mess = cab.CName + " - Công suất kháng "+index+" = 0 => Cảnh báo tủ có thể có đèn tắt"
                            }
                            msgNoti.Msg = mess
                        
                            let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                            if(bflag){
                                self.CallNotification(mess)
                            }
                        
                        }
                    }
                    
                }
                else
                {
                    if(Double(value)! > 0)
                    {
                        if(name == "t_dong")
                        {
                            mess = cab.CName + " - Dòng "+index+" > 0 => Cảnh báo tủ có thể có đèn sáng"
                            
                        }
                        else if(name == "t_csthuc")
                        {
                            mess = cab.CName + " - Công suất thực "+index+" > 0 => Cảnh báo tủ có thể có đèn sáng"
                        }
                        else if(name == "t_congsuatbieukien")
                        {
                            mess = cab.CName + " - Công suất biểu kiến "+index+" > 0 => Cảnh báo tủ có thể có đèn sáng"
                        }
                        else if(name == "t_cskhang")
                        {
                            mess = cab.CName + " - Công suất kháng "+index+" > 0 => Cảnh báo tủ có thể có đèn sáng"
                        }
                        msgNoti.Msg = mess
                        
                        let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
                        if(bflag){
                            self.CallNotification(mess)
                        }
                        
                        
                        
                    }
                    
                }
                
            }
            
        }
        if(name == "t_csthuc")
        {
            if(index == "1")
            {
                cab.CS1 = value
            }
            else if(index == "2")
            {
                cab.CS2 = value
            }
            else if(index == "3")
            {
                cab.CS3 = value
            }
            
        }
    }
    func GetTime(cab : oCabinet) -> Array<oTime>
    {
        var ListTimeResult: Array<oTime> = Array()
        var timeonresult : oTime = cab.ListBranch[0].TimeOn
        
        var timeoffresult : oTime = cab.ListBranch[0].TimeOff
        for i in 1...cab.ListBranch.count - 1
        {
            let timeon = cab.ListBranch[i].TimeOn
            let timeoff = cab.ListBranch[i].TimeOff
            if(timeon.second < timeonresult.second)
            {
                timeonresult = timeon
                
            }
            if(timeoff.second > timeoffresult.second)
            {
                timeoffresult = timeoff
            }
        }
        ListTimeResult.append(timeonresult)
        ListTimeResult.append(timeoffresult)
        return ListTimeResult
    }
    func  AddTemp(cab : oCabinet)  {
        ArrTemp = Array()
        ArrTemp.append(cab)
    }
    func ScanBranchOfCab(_ cab:oCabinet)
    {
        //print("----------ScanBranchOfCab----------")
        for i in 0...cab.ListBranch.count - 1
        {
            
            var nhanh = i + 1
            let scriptUrl = "http://112.213.95.102:1501/panel/read_branch_status/" + (cab.CSerial) + "/" + String(nhanh)  + "/1"
            //print(scriptUrl)
            let myUrl = URL(string: scriptUrl);
            
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
                
                
            }
            
            task.resume()
            sleep(1/2)
        }
        
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        //if notification.request.identifier == String(dem){
            
            completionHandler( [.alert,.sound, .badge])
            
        //}
    }
    
    func CheckTimeSchedule(timeON : oTime,timeOFF : oTime,second : Int) -> Bool {
        // true:  khung gio bat || false: khung gio tat
        if (timeON.second < timeOFF.second)
        {
            if (second <= timeOFF.second && second >= timeON.second) {
                return true
            }
            else
            {
                return false
            }
        }
        else if (timeON.second > timeOFF.second){
            if (second <= timeON.second && second >= timeOFF.second)
            {
                return false
            }
            else
            {
                return true
            }
            
        }
        else
        {
            if (second == timeON.second)
            {
                return true
            }
            else
            {
                return false
            }
            
        }
    }
    func CheckTimeScheduleOfCab(cab : oCabinet , branch : Int , seconds: Int) -> Bool
    {
        let timeon = cab.ListBranch[branch].TimeOn
        let timeoff = cab.ListBranch[branch].TimeOff
        
        let kq : Bool = self.CheckTimeSchedule(timeON: timeon, timeOFF: timeoff, second: seconds )
        return kq
        
    }
    
    func CheckBranchStatus(cab:oCabinet) -> Bool {
        for i in 0...cab.ListBranch.count - 1
        {
            if(cab.ListBranch[i].Status == HomeViewController.Status_Branch.on)
            { return false}
        }
        return true
    }
    
}


