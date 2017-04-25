//
//  HomeViewController.swift
//  Swift-Slide-Menu
//
//  Created by Philippe Boisney on 05/10/2015.
//  Copyright © 2015 Philippe Boisney. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import UserNotificationsUI
class CustomCabinetAnnotation: MKPointAnnotation {
    var imageName: String!
    var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var CNAME: String!
    var CID: String!
}
class CustomDeviceAnnotation: MKPointAnnotation {
    var imageName: String!
    var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var DNAME: String!
    var DID: String!
}
let ThemeColor   = UIColor.darkGray
class HomeViewController: ChildViewController, MKMapViewDelegate , CLLocationManagerDelegate , UNUserNotificationCenterDelegate{
    
    enum Status_Cab: Int {
        case connected = 1
        case disConnected = 0
        case connected_DS = 2
        
    }
    enum Status_Branch: Int {
        case on = 1
        case off = 0
        case none = -1
        
        
    }
    @IBOutlet weak var Map: MKMapView!
    struct MyVariables {
        static var ListCabinet: Array<oCabinet> = Array()
        static var ListWarning: Array<oWarning> = Array()
        static var ListAnnotation: Array<CustomCabinetAnnotation> = Array()
        static var isGrantedNotificationAccess:Bool = false
        static var ListMsgNotificion: Array<oMsgNotification> = Array()
        static var MinuteOfMsg : Int = 2
        static var MinuteOfMsg1 : Int = 1
        static var MinuteLimit : Int = 10
        static var indexAnnotation : Int = -1
        static var iconChange: Bool = false
    }
    
    let locationManager = CLLocationManager()
    var cabAnnotation:CustomCabinetAnnotation!
    var devAnnotation:CustomDeviceAnnotation!
    var pincabAnnotationView:MKPinAnnotationView!
    var pindevAnnotationView:MKPinAnnotationView!
    var presentWindow : UIWindow?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var scancab: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.hr_setToastThemeColor(color: ThemeColor)
        presentWindow = UIApplication.shared.keyWindow
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            //UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier!)
        })
        
        SocketIOManager.sharedInstance.establishConnection()
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert,.sound,.badge],
                completionHandler: { (granted,error) in
                    MyVariables.isGrantedNotificationAccess = granted
            }
            )
        } else {
            // Fallback on earlier versions
        }
        
        self.Map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        Map.showsUserLocation = true
        
        
        //        // set initial location in Honolulu
        //        let initialLocation = CLLocation(latitude: 10.790399, longitude: 106.642517)
        //
        //        // Do any additional setup after loading the view.
        //
        //        centerMapOnLocation(initialLocation)
        
        _ = Timer.scheduledTimer(timeInterval: 50, target: self, selector: #selector(HomeViewController.timerScanCab), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(HomeViewController.timerScanBranchOfCab_Version_2), userInfo: nil, repeats: true)
        
        _ = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(HomeViewController.timerScanBranchOfCab_Version_1), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeViewController.timerUpdateIcon), userInfo: nil, repeats: true)
        LoadCabinet()
        
        LoadWarningActive()
        
        
        
        //LoadDevices()
        
        
    }
    func appMovedToBackground() {
        
        for i in 0...MyVariables.ListCabinet.count - 1
        {
            let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
                print(MyVariables.ListCabinet[i].CName)
            }
        }
    }
    func timerScanCab() {
        ScanCab()
    }
    func timerUpdateIcon() {
        if(MyVariables.iconChange)
        {
            self.Map.removeAnnotation((MyVariables.ListAnnotation[MyVariables.indexAnnotation] as? MKAnnotation)!)
            self.Map.addAnnotation(MyVariables.ListAnnotation[MyVariables.indexAnnotation])
//            print("-----------------------" + MyVariables.ListAnnotation[MyVariables.indexAnnotation].CNAME + " , trạng thái : " + MyVariables.ListAnnotation[MyVariables.indexAnnotation].imageName)
//            
            MyVariables.iconChange = false
        }
        if(scancab)
        {
            if(MyVariables.ListCabinet.count == 0) {return}
            for i in 0...MyVariables.ListCabinet.count - 1
            {
                self.Map.removeAnnotation((MyVariables.ListAnnotation[i] as? MKAnnotation)!)
                self.Map.addAnnotation(MyVariables.ListAnnotation[i])
                
            }
            //print("scancab-------------")
            scancab = false
        }
    }
    func timerScanBranchOfCab_Version_2() {
        ScanBranchOfCab_Version_2()
        CapNhatTinhTrangCabinet()
        CanhBaoNhayCB()
        
    }
    func timerScanBranchOfCab_Version_1() {
        do{
            if(MyVariables.ListCabinet.count == 0) {return}
            for i in 0...MyVariables.ListCabinet.count - 1
            {
                let cab = MyVariables.ListCabinet[i]
                if(cab.Status == Status_Cab.connected || cab.Status == Status_Cab.connected_DS)
                {
                    ScanBranchOfCab_Version_1(cab)
                }
            }
        }
        catch {
            
            print("error serializing JSON: \(error)")
            
        }
    }
    func CanhBaoNhayCB()
    {
        if(MyVariables.ListCabinet.count == 0) {return}
        //get current time
        let date = Date()
        let calendar = Calendar.current
        
        
        var hour : Int = 0
        var minutes : Int = 0
        var seconds : Int = 0
        
        for j in 0...MyVariables.ListCabinet.count - 1
        {
            let cab = MyVariables.ListCabinet[j]
            if(cab.CS1 == "0.00" && cab.CS2 == "0.00" && cab.CS3 == "0.00")
            {
                var flag : Bool = false
                for i in 0...cab.ListBranch.count - 1
                {
                    if(cab.ListBranch[i].Status == Status_Branch.on)
                    {
                        flag = true
                    }
                }
                if(!flag)
                {
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
                    let ListTimeResult : Array<oTime> = GetTime(cab: cab)
                    let timeon = ListTimeResult[0]
                    let timeoff = ListTimeResult[1]
                    //                print ("timeon : " + String(timeon.hour) + ":" + String(timeon.minute))
                    //                print ("timeoff : " + String(timeoff.hour) + ":" + String(timeoff.minute))
                    let kq : Bool = self.CheckTimeSchedule(timeON: timeon, timeOFF: timeoff, second: seconds )
                    if(kq)//nhanh dang trong khung gio bat
                    {
                        if(self.CheckTimeForCS(secondCurrent: seconds, secondOn: timeon.second))
                        {
                            let mess : String = "Cảnh báo tủ " + cab.CName + " có thể nhảy RCCB"
                            let msgNoti : oMsgNotification = oMsgNotification()
                            msgNoti.Serial = (cab.CSerial)
                            msgNoti.Loai = "RCCB"
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
    func CapNhatTinhTrangCabinet()
    {
        print("####################---Danh Sach Cabinet---#################")
        if(MyVariables.ListCabinet.count == 0) {return}
        for j in 0...MyVariables.ListCabinet.count - 1
        {
            let cab = MyVariables.ListCabinet[j]
            if(cab.ONOFFBranch)
            {
                for i in 0...cab.ListBranch.count - 1
                {
                    if(i>2) { continue }
                    
                    var nhanh:String = (cab.ListBranch[i].Status == Status_Branch.on) ? "1": "0"
                    var message: String = cab.CName + " nhánh: (" + String(i) + "-" + nhanh + ")- giờ: (" + cab.GioHeThongTu + ")"
                    if(cab.ONOFFBranch)
                    {
                        message += " - " + String(cab.ListBranch[i].TimeOn.hour) + ":" + String(cab.ListBranch[i].TimeOn.minute) + " -> " + String(cab.ListBranch[i].TimeOff.hour) + ":" + String(cab.ListBranch[i].TimeOff.minute)
                    }
                    print(message)
                    
                    
                    // print(cab.CName + " nhánh: " + i + "-" + String(ListBranchTemp[i]))
                    
                }
                
            }
        }
       
        if(MyVariables.ListMsgNotificion.count == 0) {return}
        print("-------------------------------")
        for j in 0...MyVariables.ListMsgNotificion.count - 1
        {
            let mess = MyVariables.ListMsgNotificion[j]
            var message: String = mess.Msg + " Loại : (" + mess.Loai + ") thời gian: (" + mess.sThoiGian + ")"
            print(message)
        }
    }
    func LoadTimeSchedule() {
        
        let scriptUrl = "http://112.213.95.102:1501/android/googlemaps/kssc/getallschedule"
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
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                
                
                if let DStimeschedule = json as? [[String: AnyObject]] {
                    for time in DStimeschedule {
                        let CabID  = (time["CabID"] as? String)!
                        let Type  = (time["Type"] as? String)!
                        let TypeOfChange  = (time["TypeOfChange"] as? String)!
                        let hour  = (time["Hour"] as? Int)!
                        let minute  = (time["Minute"] as? Int)!
                        let branchindex  = (time["BranchIndex"] as? Int)!
                        let time : oTime = oTime()
                        time.hour = hour
                        time.minute = minute
                        time.second = hour * 3600 + minute * 60
                        if(MyVariables.ListCabinet.count == 0) {return}
                        for i in 0...MyVariables.ListCabinet.count - 1
                        {
                            let cab = MyVariables.ListCabinet[i]
                            if(cab.CID == CabID)
                            {
                                if(Type == "TU")
                                {
                                    cab.ONOFF = true
                                    if(TypeOfChange == "ON")
                                    {
                                        cab.TimeOn = time
                                    }
                                    else
                                    {
                                        cab.TimeOff = time
                                    }
                                }
                                else if(Type == "NHANH")
                                {
                                    cab.ONOFFBranch = true
                                    if(TypeOfChange == "ON")
                                    {
                                        cab.ListBranch[branchindex - 1].TimeOn = time
                                    }
                                    else
                                    {
                                        cab.ListBranch[branchindex - 1].TimeOff = time
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                //self.timerScanBranchOfCab_Version_1()
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        
        
    }
    
    func LoadCabinet() {
        //let scriptUrl = "http://112.213.95.102:1508/qldl/getallcabinet"
        let scriptUrl = "http://112.213.95.102:1508/android/googlemaps/kssc/getcabinetbyusername_update/" + LoginViewController.MyVariables.username
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
            do {
                MyVariables.ListCabinet = Array()
                MyVariables.ListAnnotation = Array()
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                
                if let dsallcab = json as? [[[String: AnyObject]]] {
                    if let dscab = dsallcab[0] as? [[String: AnyObject]] {
                        for cab in dscab {
                            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((cab["ALAT"] as! NSString).doubleValue), longitude: Double((cab["ALNG"] as! NSString).doubleValue))
                            self.cabAnnotation = CustomCabinetAnnotation()
                            self.cabAnnotation.imageName = "cabinet"
                            self.cabAnnotation.CNAME = cab["CNAME"] as? String
                            self.cabAnnotation.CID = cab["CID"] as? String
                            self.cabAnnotation.coord = location
                            ///////////
                            
                            let cabnew : oCabinet = oCabinet()
                            cabnew.CID = (cab["CID"] as? String)!
                            cabnew.CName = (cab["CNAME"] as? String)!
                            cabnew.CSerial = (cab["CSERIAL"] as? String)!
                            var slnhanh:Int = (cab["CBRCOUNT"] as? Int)!
                            
                            for i in 0...slnhanh - 1
                            {
                                let branch : oBranch = oBranch()
                                cabnew.ListBranch.append(branch)
                            }
                            
                            MyVariables.ListCabinet.append(cabnew)
                            /////////
                            self.cabAnnotation.coordinate = location
                            self.cabAnnotation.title = cab["CNAME"] as? String
                            self.pincabAnnotationView = MKPinAnnotationView(annotation: self.cabAnnotation, reuseIdentifier: "cabinet")
                            self.Map.addAnnotation(self.pincabAnnotationView.annotation!)
                            MyVariables.ListAnnotation.append((self.pincabAnnotationView.annotation as? CustomCabinetAnnotation)!)
                            
                        }
                        self.ScanCab()
                        self.ScanBranchOfCab_Version_2()
                        
                    }
                    
                    
                }
                
                self.LoadTimeSchedule()
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        
        
    }
    func LoadDevices() {
        let scriptUrl = "http://112.213.95.102:1508/qldl/getalldevice"
        let myUrl = URL(string: scriptUrl);
        let request = NSMutableURLRequest(url:myUrl!);
        request.httpMethod = "GET"
        //        let task = URLSession.shared.dataTask(with: request, completionHandler: {
        //            data, response, error in
        //
        //            // Check for error
        //            if error != nil
        //            {
        //                print("error=\(error)")
        //                return
        //            }
        //            do {
        //                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
        //
        //
        //                if let dsdev = json as? [[String: AnyObject]] {
        //                    for dev in dsdev {
        //                        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((dev["ALAT"] as! NSString).doubleValue), longitude: Double((dev["ALNG"] as! NSString).doubleValue))
        //                        self.devAnnotation = CustomDeviceAnnotation()
        //                        self.devAnnotation.imageName = "device"
        //                        self.devAnnotation.DNAME = dev["DNAME"] as? String
        //                        self.devAnnotation.DID = dev["DID"] as? String
        //                        self.devAnnotation.coord = location
        //                        ////////
        //                        self.devAnnotation.coordinate = location
        //                        self.devAnnotation.title = dev["DNAME"] as? String
        //                        self.pindevAnnotationView = MKPinAnnotationView(annotation: self.devAnnotation, reuseIdentifier: "device")
        //                        self.Map.addAnnotation(self.pindevAnnotationView.annotation!)
        //
        //
        //
        //                    }
        //                }
        //            } catch {
        //                print("error serializing JSON: \(error)")
        //            }
        //
        //
        //        })
        //        task.resume()
        
    }
    func LoadWarningActive() {
        let scriptUrl = "http://112.213.95.102:1501/android/getalertsettings"
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
            do {
                MyVariables.ListWarning = Array()
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let dswarning = json as? [[String: AnyObject]] {
                    for wa in dswarning {
                        
                        if(wa["IsActive"] as? Int == 1)
                        {
                            let wanew : oWarning = oWarning()
                            wanew.mKey = (wa["mKey"] as? String)!
                            wanew.IsActive = "1"
                            wanew.Status = (wa["Status"] as? Int)!
                            wanew.Value_Max = (wa["Value_Min"] as? Int)!
                            wanew.Value_Min = (wa["Value_Max"] as? Int)!
                            MyVariables.ListWarning.append(wanew)
                            
                        }
                    }
                    
                    
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        
    }
    
    static func UpdateIconCabOnMap(_ vtCab : Int)
    {
        //        print("----------UpdateIconCabOnMap----------")
        
        let cab = MyVariables.ListCabinet[vtCab] as? oCabinet
        var img:String=""
        
        if(cab?.Status == Status_Cab.connected)
        {
            img = "cabinet_on"
            
        }
        else if(cab?.Status == Status_Cab.connected_DS)
        {
            img = "cabinet_ds"
        }
        else
        {
            img = "cabinet"
        }
        
        MyVariables.ListAnnotation[vtCab].imageName = img
        MyVariables.indexAnnotation = vtCab
        MyVariables.iconChange = true
        
        
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0] as CLLocation
        let region = MKCoordinateRegion(center: (currentLocation.coordinate), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        Map.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (view.annotation is CustomCabinetAnnotation)
        {
            if (control as? UIButton)?.buttonType == UIButtonType.custom {
                let c = view.annotation as! CustomCabinetAnnotation
                // print("error=\(cab.CNAME)")
                let index = HomeViewController.MyVariables.ListCabinet.index{$0.CID == c.CID}
                let cab = HomeViewController.MyVariables.ListCabinet[index!] as? oCabinet
                CreatePopup(cab: cab! , index: index!)
                
            }
        }
        if (view.annotation is CustomDeviceAnnotation)
        {
            if (control as? UIButton)?.buttonType == UIButtonType.custom {
                let dev = view.annotation as! CustomDeviceAnnotation
                //print("error=\(dev.DNAME)")
                //ViewFunc()
                
            }
        }
    }
    func ViewFunc(_ cab:oCabinet)
    {
        let popupOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spPopupID") as! PopupViewController
        self.addChildViewController(popupOverVC)
        popupOverVC.view.frame = self.view.frame
        popupOverVC.BindingCab(cab)
        self.view.addSubview(popupOverVC.view)
        popupOverVC.didMove(toParentViewController: self)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is CustomCabinetAnnotation)
        {
            let reuseId = "cabinet"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                let image = UIImage(named: "settings")
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                button.setImage(image, for: UIControlState())
                
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView!.canShowCallout = true
                anView!.rightCalloutAccessoryView = button
                
                anView!.calloutOffset = CGPoint(x: 0, y: 4)
                anView!.contentMode = .scaleAspectFill
            }
            else {
                anView!.annotation = annotation
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            let cpa = annotation as! CustomCabinetAnnotation
            anView!.image = UIImage(named:cpa.imageName)
            
            return anView
        }
        if (annotation is CustomDeviceAnnotation)
        {
            let reuseId = "device"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView!.canShowCallout = true
                anView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
                anView!.calloutOffset = CGPoint(x: 0, y: 4)
                anView!.contentMode = .scaleAspectFill
            }
            else {
                anView!.annotation = annotation
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            let cpa = annotation as! CustomDeviceAnnotation
            anView!.image = UIImage(named:cpa.imageName)
            
            return anView
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    let regionRadius: CLLocationDistance = 200
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        Map.setRegion(coordinateRegion, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func ScanCab()
    {
        do
        {
            print("----------ScanCab----------")
            if(MyVariables.ListCabinet.count == 0) {return}
            for i in 0...MyVariables.ListCabinet.count - 1
            {
                var cab = MyVariables.ListCabinet[i] as? oCabinet
                let scriptUrl = "http://112.213.95.102:1501/panel/status/" + (cab?.CSerial)!+"/1"
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
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        var img:String=""
                        
                        if((json as AnyObject).intValue == 1)
                        {
                            img = "cabinet_on"
                            cab?.Status = Status_Cab.connected
                            cab?.StatusOld = Status_Cab.connected
                            
                        }
                        else if((json as AnyObject).intValue == 2)
                        {
                            img = "cabinet_ds"
                            cab?.Status = Status_Cab.connected_DS
                            cab?.StatusOld = Status_Cab.connected_DS
                        }
                        else if((json as AnyObject).intValue == 0)
                        {
                            img = "cabinet"
                            cab?.Status = Status_Cab.disConnected
                            cab?.StatusOld = Status_Cab.disConnected
                        }
                        
                        MyVariables.ListAnnotation[i].imageName = img
                        
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                    
                    
                }
                
                task.resume()
                sleep(1/2)
            }
            scancab = true
            
        } catch {
            
        }
        
    }
    func ScanCabForSerial(cab : oCabinet , index : Int)
    {
        let semaphore = DispatchSemaphore(value: 0);
        let scriptUrl = "http://112.213.95.102:1501/panel/status/" + (cab.CSerial) + "/1"
        
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
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                var img:String=""
                
                if((json as AnyObject).intValue == 1)
                {
                    img = "cabinet_on"
                    cab.Status = Status_Cab.connected
                    cab.StatusOld = Status_Cab.connected
                    
                }
                else if((json as AnyObject).intValue == 2)
                {
                    img = "cabinet_ds"
                    cab.Status = Status_Cab.connected_DS
                    cab.StatusOld = Status_Cab.connected_DS
                }
                else
                {
                    img = "cabinet"
                    cab.Status = Status_Cab.disConnected
                    cab.StatusOld = Status_Cab.disConnected
                }
                //img = "cabinet"
                MyVariables.ListAnnotation[index].imageName = img
                
                print("Trang thai ket noi: \(json)")
                semaphore.signal();
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        semaphore.wait(timeout: DispatchTime.distantFuture);
        if self.Map.selectedAnnotations.count > 0 {
            
            if let ann = self.Map.selectedAnnotations[0] as? MKAnnotation {
                
                //print("selected annotation: \(ann.title!)")
                
                let c = ann.coordinate
               // print("coordinate: \(c.latitude), \(c.longitude)")
                
                //do something else with ann...
                self.Map.removeAnnotation(ann)
                self.Map.addAnnotation(MyVariables.ListAnnotation[index])
                var sta_cab : String = ""
                if(cab.Status == Status_Cab.connected)
                { sta_cab = "Kết nối - Đèn tắt"}
                else if(cab.Status == Status_Cab.connected_DS)
                { sta_cab = "Kết nối - Đèn sáng"}
                else if(cab.Status == Status_Cab.disConnected)
                { sta_cab = "Mất kết nối"}
                presentWindow!.makeToast(message: "Tủ \(cab.CName) - Trạng thái: " + sta_cab)
            }
        }
        
    }
    
    func ScanBranchOfCab_Version_2() {
        print("----------ScanBranchOfCab_Version_2----------")
        let scriptUrl = "http://112.213.95.102:1508/android/getthongsotu"
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
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                if let dstrangthainhanh = json as? [[String: AnyObject]] {
                    for ttnhanh in dstrangthainhanh {
                        let Serial : String = ttnhanh["Serial"] as! String
                        
                        let cab = self.GetCabBySerial(Serial)
                        if(cab.CID == ""){ continue }
                        var ListBranchTemp: Array<Int> = Array()
                        let TTN1 : Int = ttnhanh["TTN1"] as! Int
                        ListBranchTemp.append(TTN1)
                        let TTN2 : Int = ttnhanh["TTN2"] as! Int
                        ListBranchTemp.append(TTN2)
                        let TTN3 : Int = ttnhanh["TTN3"] as! Int
                        ListBranchTemp.append(TTN3)
                        
                        for i in 0...cab.ListBranch.count - 1
                        {
                            if(i>2) { break }
                            if(ListBranchTemp[i] != -1)
                            {
                                cab.ListBranch[i].Status = (ListBranchTemp[i] == 0) ? Status_Branch.off : Status_Branch.on
                                var message: String = cab.CName + " nhánh: (" + String(i) + "-" + String(ListBranchTemp[i]) + ")- giờ: (" + cab.GioHeThongTu + ")"
                                if(cab.ONOFFBranch)
                                {
                                    message += " - " + String(cab.ListBranch[0].TimeOn.hour) + ":" + String(cab.ListBranch[0].TimeOn.minute) + " -> " + String(cab.ListBranch[0].TimeOff.hour) + ":" + String(cab.ListBranch[0].TimeOff.minute)
                                }
                                //print(message)
                                
                                
                                // print(cab.CName + " nhánh: " + i + "-" + String(ListBranchTemp[i]))
                            }
                        }
                    }
                    
                    
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        
    }
    func GetCabBySerial(_ Serial : String) -> oCabinet {
        let index = MyVariables.ListCabinet.index{$0.CSerial == Serial}
        if(index != nil)
        {
            let cab = MyVariables.ListCabinet[index!] as? oCabinet
            return cab!
            
        }
        return oCabinet()
    }
    func ReadTimeSystem(Serial : String)
    {
        
        let scriptUrl = "http://112.213.95.102:1501/panel/read_time/" + Serial  + "/1"
        
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
        
    }
    
    func ScanBranchOfCab_Version_1(_ cab:oCabinet)
    {
        
        if(cab.ONOFFBranch)
        {
            //get current time
            let date = Date()
            let calendar = Calendar.current
            
            
            var hour : Int = 0
            var minutes : Int = 0
            var seconds : Int = 0
            
            
            
            
            
            if(cab.GioHeThongTu == "---")
            {
                hour = calendar.component(.hour, from: date)
                minutes = calendar.component(.minute, from: date)
                seconds = calendar.component(.second, from: date) + hour * 3600 + minutes * 60
                ReadTimeSystem(Serial: cab.CSerial)
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
                else
                {
                    print(String(values.count))
                }
            }
            
            
            for i in 0...cab.ListBranch.count - 1
            {
                if(i > 2) {break}
                let timeon = cab.ListBranch[i].TimeOn
                let timeoff = cab.ListBranch[i].TimeOff
                var flag : Bool = false
                let kq : Bool = self.CheckTimeSchedule(timeON: timeon, timeOFF: timeoff, second: seconds )
                if(kq)//nhanh dang trong khung gio bat
                {
                    if(cab.ListBranch[i].Status == Status_Branch.off )
                    {
                        flag = true
                    }
                }
                else//nhanh dang trong khung gio tat
                {
                    if(cab.ListBranch[i].Status == Status_Branch.on)
                    {
                        flag = true
                    }
                }
                if(flag)
                {
//                    let msgNoti : oMsgNotification = oMsgNotification()
//                    msgNoti.Serial = (cab.CSerial)
//                    msgNoti.Loai = "NHANH"
//                    msgNoti.ChiSo = (i+1)
//                    msgNoti.ThoiGian = seconds
//                    msgNoti.Msg = ""
//                    msgNoti.sThoiGian = String(hour) + ":" + String(minutes)
                   // print(seconds)
//                    let bflag :Bool =  self.CheckAvaibleMsgNotification(msg: msgNoti)
//                    if(bflag){
                        print("ScanBranchOfCab_Version_1: " + cab.CName + " : nhánh " + String(i+1))
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
                       // sleep(1)
                        
                    //}
                    
                }
            }
        }
        
    }
    func CreatePopup(cab:oCabinet ,index:Int)  {
        let alert = UIAlertController(title: "Tủ: " + cab.CName,
                                      message: "Trạng thái: " + (cab.Status == HomeViewController.Status_Cab.connected ? "Kết nối - Đèn Tắt" : cab.Status == HomeViewController.Status_Cab.connected_DS ? "Kết nối - Đèn Sáng" : "Mất kết nối"),
                                      preferredStyle: .alert)
        
        var hour : Int = 0
        var minutes : Int = 0
        var seconds : Int = 0
        let date = Date()
        let calendar = Calendar.current
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
        let ListTimeResult : Array<oTime> = self.GetTime(cab: cab)
        let timeon = ListTimeResult[0]
        let timeoff = ListTimeResult[1]
        
        let action1 = UIAlertAction(title: "Bật Tủ", style: .default, handler: { (action) -> Void in
            
            let kq : Bool = self.CheckTimeSchedule(timeON: timeon, timeOFF: timeoff, second: seconds )
            if(kq)//nhanh dang trong khung gio bat
            {
                
            }
            else//nhanh dang trong khung gio tat
            {
                self.presentWindow!.makeToast(message: "Tủ \(cab.CName) đang trong khung giờ Tắt không được Bật ")
            }
            

        })
        
        let action2 = UIAlertAction(title: "Tắt Tủ", style: .default, handler: { (action) -> Void in
            let kq : Bool = self.CheckTimeSchedule(timeON: timeon, timeOFF: timeoff, second: seconds )
            if(kq)//nhanh dang trong khung gio bat
            {
                 self.presentWindow!.makeToast(message: "Tủ \(cab.CName) đang trong khung giờ Bật không được Tắt ")
            }
            else//nhanh dang trong khung gio tat
            {
               
            }
        })
        
        let action3 = UIAlertAction(title: "Đọc Trạng Thái", style: .default, handler: { (action) -> Void in
            self.ScanCabForSerial(cab: cab,index: index)
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Thoát", style: .destructive, handler: { (action) -> Void in })
        
        // Add action buttons and present the Alert
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func CheckAvaibleMsgNotification(msg : oMsgNotification) -> Bool {
        if(MyVariables.ListMsgNotificion.count == 0)
        {
            MyVariables.ListMsgNotificion.append(msg)
            return true
        }
        for i in 0...MyVariables.ListMsgNotificion.count - 1
        {
            let noti = MyVariables.ListMsgNotificion[i]
            if(noti.Loai != msg.Loai) { continue}
            if(msg.Loai == "NHANH" && msg.Serial == noti.Serial && msg.ChiSo == noti.ChiSo)
            {
                
                if(msg.ThoiGian - noti.ThoiGian >= (MyVariables.MinuteOfMsg1 * 60))
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
            else if(msg.Loai == "RCCB" && msg.Serial == noti.Serial)
            {
                if(msg.ThoiGian - noti.ThoiGian >= (MyVariables.MinuteOfMsg * 60))
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
        
        MyVariables.ListMsgNotificion.append(msg)
        return true
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
    var dem:Int = 1000
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
//            content.title = "Cảnh báo sự cố"
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
    func CheckTimeForCS(secondCurrent : Int , secondOn : Int) -> Bool
    {
        let diff = secondCurrent - secondOn
        if(abs(diff) < HomeViewController.MyVariables.MinuteLimit * 60)
        {
            return false
        }
        return true
    }
    
}

