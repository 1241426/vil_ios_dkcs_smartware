//
//  ContactViewController.swift
//  Swift-Slide-Menu
//
//  Created by Philippe Boisney on 05/10/2015.
//  Copyright © 2015 Philippe Boisney. All rights reserved.
//

import UIKit

class ContactViewController: ChildViewController, UITableViewDelegate, UITableViewDataSource{
    var displayArray = [TreeViewNode]()
    @IBOutlet weak var btnThunho: UIButton!
    @IBAction func ThuNho(_ sender: Any) {
        CollapseAllNode()
    }
    @IBAction func PhongTo(_ sender: Any) {
        ExpandAllNode()
    }
    @IBOutlet weak var btnPhongto: UIButton!
    var ListCabinetForTreeViews = [oCabinet]()
    @IBOutlet weak var tableView1: UITableView!
    var indentation: Int = 0
    var nodes: [TreeViewNode] = []
    
    var dataTree: [TreeViewData] = []
     var presentWindow : UIWindow?
    let ThemeColor   = UIColor.darkGray
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: ThemeColor)
        presentWindow = UIApplication.shared.keyWindow

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactViewController.ExpandCollapseNode(_:)), name: NSNotification.Name(rawValue: "TreeNodeButtonClicked"), object: nil)
        
        
        
        let image = UIImage(named: "whiteOpen")?.withRenderingMode(.alwaysOriginal) as UIImage?
        btnPhongto.frame = CGRect(x: 100, y: 100, width: 70, height: 70)
        btnPhongto.setImage(image, for: .normal)
        btnPhongto.backgroundColor = .clear
        btnPhongto.layer.cornerRadius = 5
        btnPhongto.layer.borderWidth = 1
        btnPhongto.layer.borderColor = UIColor.black.cgColor
        btnPhongto.imageEdgeInsets = UIEdgeInsetsMake(8,8,8,8);
        let image1 = UIImage(named: "whiteClose")?.withRenderingMode(.alwaysOriginal) as UIImage?
        btnThunho.frame = CGRect(x: 100, y: 100, width: 70, height: 70)
        btnThunho.setImage(image1, for: .normal)
        btnThunho.backgroundColor = .clear
        btnThunho.layer.cornerRadius = 5
        btnThunho.layer.borderWidth = 1
        btnThunho.layer.borderColor = UIColor.black.cgColor
        
        btnThunho.imageEdgeInsets = UIEdgeInsetsMake(8,8,8,8);
        
        LoadCabinetForTreeView()
        
        
    }
    
    func DemSLQuan(_ data : [[String: AnyObject]],idQuan : Int) -> Int
    {
        var count : Int = 0
        for cab in data {
            let idQ  = (cab["IDQuan"] as? Int)!
            if idQ == idQuan {
                count += 1
                
            }
            
            
        }
        return count
    }
    func DemSLDuong(_ data : [[String: AnyObject]],idDuong : Int) -> Int
    {
        var count : Int = 0
        for cab in data {
            let idD  = (cab["RoadID"] as? Int)!
            if idD == idDuong {
                count += 1
                
            }
            
            
        }
        return count
    }
    
    func LoadCabinetForTreeView() {
        print("SLCab=\(HomeViewController.MyVariables.ListCabinet.count)")
        let semaphore = DispatchSemaphore(value: 0);
        let scriptUrl = "http://112.213.95.102:1501/android/googlemaps/kssc/gettreeview"
        let myUrl = URL(string: scriptUrl);
        
        var ListQuan : Array<NodeTree> = Array()
        
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
                var indexTu:Int = 0
                
                var countSLTu : Int = 0;
                
                if let dscab = json as? [[String: AnyObject]] {
                    
                    
                    var i:Int = 0
                    while i < dscab.count
                    {
                        // Quận
                        let ListNodeOfQuan : Array<NodeTree> = Array()
                        let NodeQuan: NodeTree = NodeTree(NodeName: (dscab[i]["NameDis"] as? String)! , tags: "Q-" + (String(describing: dscab[i]["IDQuan"] as? Int)), Image: "", ListNode: ListNodeOfQuan,CID: (dscab[i]["IDCab"] as? String)!,SLTu: 0)!
                        
                        let countQ = self.DemSLQuan(dscab, idQuan: (dscab[i]["IDQuan"] as? Int)!)
                        var ListDuong : Array<NodeTree> = Array()
                        var countSLTuQ : Int = 0;
                        
                        var j:Int = i
                        while j < (i + countQ)
                        {
                            //Phường
                            let ListNodeOfDuong : Array<NodeTree> = Array()
                            let NodeDuong: NodeTree = NodeTree(NodeName: (dscab[j]["NameRoad"] as? String)! , tags: "D-" + (String(describing: dscab[j]["RoadID"] as? Int)), Image: "", ListNode:ListNodeOfDuong,CID: (dscab[j]["IDCab"] as? String)!,SLTu: 0)!
                            
                            let countD = self.DemSLDuong(dscab, idDuong:  (dscab[j]["RoadID"] as? Int)!)
                            
                            var ListTu : Array<NodeTree> = Array()
                            var k:Int = j
                            while k < (j+countD)
                            {
                                let IDTu = dscab[k]["IDCab"] as! String
                                let index = HomeViewController.MyVariables.ListCabinet.index{$0.CID ==  IDTu}
                                
                                if(index != nil)
                                {
                                    
                                    
                                    //Tủ
                                    let ListNodeOfTu : Array<NodeTree> = Array()
                                    let NodeTu: NodeTree = NodeTree(NodeName: (dscab[k]["NameCab"] as? String)! , tags: "T-" + (dscab[k]["IDCab"] as? String)!, Image: "", ListNode: ListNodeOfTu,CID: (dscab[k]["IDCab"] as? String)!,SLTu: 0)!
                                    ListTu.append(NodeTu)
                                    indexTu += 1;
                                    
                                }
                                k+=1
                            }
                            countSLTuQ += ListTu.count;
                            countSLTu += ListTu.count;
                            // NodeDuong.setSLTu(" ("+ListTu.count+")");
                            NodeDuong.ListNode = ListTu
                            if(ListTu.count > 0)
                            { ListDuong.append(NodeDuong) }
                            
                            
                            j += countD
                            
                        }
                        
                        
                        // NodeQuan.setSLTu(" ("+countSLTuQ+")");
                        NodeQuan.ListNode = ListDuong;
                        if(ListDuong.count > 0)
                        { ListQuan.append(NodeQuan) }
                        i += countQ
                        
                        
                    }
                    semaphore.signal();
                    
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        semaphore.wait(timeout: DispatchTime.distantFuture);
        if(ListQuan.count == 0) {return}
        self.dataTree = TreeViewLists.LoadInitialData(ListQuan)
        self.nodes = TreeViewLists.LoadInitialNodes(self.dataTree)
        self.LoadDisplayArray()
        self.tableView1.reloadData()
        
        
    }
    func CreatePopup(cab:oCabinet , cell : TreeViewCell ,index:Int)  {
        let alert = UIAlertController(title: "Tủ: " + cab.CName,
                                      message: "Trạng thái: " + (cab.Status == HomeViewController.Status_Cab.connected ? "Kết nối - Đèn Tắt" : cab.Status == HomeViewController.Status_Cab.connected_DS ? "Kết nối - Đèn Sáng" : "Mất kết nối"),
                                      preferredStyle: .alert)
        
        
        
        let action1 = UIAlertAction(title: "Bật Tủ", style: .default, handler: { (action) -> Void in
            print(cab.CName + "B")
        })
        
        let action2 = UIAlertAction(title: "Tắt Tủ", style: .default, handler: { (action) -> Void in
            print(cab.CName + "T")
        })
        
        let action3 = UIAlertAction(title: "Đọc Trạng Thái", style: .default, handler: { (action) -> Void in
            self.ScanCabForSerial(cab: cab,index: index , cell : cell)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ExpandCollapseNode(_ notification: Notification)
    {
        self.LoadDisplayArray()
        self.tableView1.reloadData()
    }
    func CollapseAllNode()
    {
        self.nodes = self.LoadInitialNodes(self.dataTree,0)
        self.LoadDisplayArray()
        self.tableView1.reloadData()
    }
    func ExpandAllNode()
    {
        self.nodes = self.LoadInitialNodes(self.dataTree,1)
        self.LoadDisplayArray()
        self.tableView1.reloadData()
    }
    func LoadInitialNodes(_ dataList: [TreeViewData] ,_ type: Int )  -> [TreeViewNode]
    {
        var nodes: [TreeViewNode] = []
        
        for data in dataList where data.level == 0
        {
            
            
            let node: TreeViewNode = TreeViewNode()
            node.nodeLevel = data.level
            node.nodeObject = data.name as AnyObject?
            node.isExpanded = (type == 1 ? GlobalVariables.TRUE : GlobalVariables.FALSE)
            node.CID = data.id
            let newLevel = data.level + 1
            node.nodeChildren = LoadChildrenNodes(dataList, level: newLevel, parentId: data.id,type)
            
            if (node.nodeChildren?.count == 0)
            {
                node.nodeChildren = nil
            }
            
            nodes.append(node)
            
        }
        
        return nodes
    }
    func LoadChildrenNodes(_ dataList: [TreeViewData], level: Int, parentId: String,_ type: Int ) -> [TreeViewNode]
    {
        var nodes: [TreeViewNode] = []
        
        for data in dataList where data.level == level && data.parentId == parentId
        {
            
            
            let node: TreeViewNode = TreeViewNode()
            node.nodeLevel = data.level
            node.nodeObject = data.name as AnyObject?
            node.isExpanded = (type == 1 ? GlobalVariables.TRUE : GlobalVariables.FALSE)
            node.CID = data.id
            let newLevel = level + 1
            node.nodeChildren = LoadChildrenNodes(dataList, level: newLevel, parentId: data.id , type)
            
            if (node.nodeChildren?.count == 0)
            {
                node.nodeChildren = nil
                node.isChildren = 1
            }
            
            nodes.append(node)
            
        }
        
        return nodes
    }
    
    func LoadDisplayArray()
    {
        self.displayArray = [TreeViewNode]()
        for node: TreeViewNode in nodes
        {
            self.displayArray.append(node)
            if (node.isExpanded == GlobalVariables.TRUE)
            {
                self.AddChildrenArray(node.nodeChildren as! [TreeViewNode])
            }
        }
    }
    
    func AddChildrenArray(_ childrenArray: [TreeViewNode])
    {
        for node: TreeViewNode in childrenArray
        {
            self.displayArray.append(node)
            if (node.isExpanded == GlobalVariables.TRUE )
            {
                if (node.nodeChildren != nil)
                {
                    self.AddChildrenArray(node.nodeChildren as! [TreeViewNode])
                }
            }
        }
    }
    
    //MARK:  Table View Methods
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return displayArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let node: TreeViewNode = self.displayArray[indexPath.row]
        
        let cell  = (self.tableView1.dequeueReusableCell(withIdentifier: "cell") as! TreeViewCell)
        let level: Int = Int(node.nodeLevel!)
        
        //print("level: \(level)")
        cell.treeNode = node
        cell.treeLabel.text = node.nodeObject as! String?
        print(String(HomeViewController.MyVariables.ListCabinet.count) + "sssss")
        if(level == 2 )
        {
            let index = HomeViewController.MyVariables.ListCabinet.index{$0.CID == node.CID}
            let cab = HomeViewController.MyVariables.ListCabinet[index!] as? oCabinet
            
            print("cabname : \(cab?.CName)")
            if(cab?.Status == HomeViewController.Status_Cab.disConnected)
            {
                cell.setTheButtonBackgroundImage(UIImage(named: "cabinet")!)
            }
            else if(cab?.Status == HomeViewController.Status_Cab.connected)
            {
                cell.setTheButtonBackgroundImage(UIImage(named: "cabinet_on")!)
            }
            else if(cab?.Status == HomeViewController.Status_Cab.connected_DS)
            {
                cell.setTheButtonBackgroundImage(UIImage(named: "cabinet_ds")!)
            }
        }
        else
        {
            if (node.isExpanded == GlobalVariables.TRUE)
            {
                cell.setTheButtonBackgroundImage(UIImage(named: "whiteOpen")!)
            }
            else
            {
                cell.setTheButtonBackgroundImage(UIImage(named: "whiteClose")!)
            }
            
        }
        
        cell.setNeedsDisplay()
        
        return cell
    }
    func ViewFunc(_ cab:oCabinet)
    {
        let popupOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spPopupID") as! PopupViewController
        self.addChildViewController(popupOverVC)
        popupOverVC.view.frame = self.view.frame
        popupOverVC.cab = cab
        popupOverVC.BindingCab(cab)
        self.view.addSubview(popupOverVC.view)
        popupOverVC.didMove(toParentViewController: self)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node: TreeViewNode = self.displayArray[indexPath.row]
   
        
        let cell  = (self.tableView1.dequeueReusableCell(withIdentifier: "cell") as! TreeViewCell)
       

        
        if(node.isChildren == 1)
        {
            let index = HomeViewController.MyVariables.ListCabinet.index{$0.CID == node.CID}
            let cab = HomeViewController.MyVariables.ListCabinet[index!] as? oCabinet
            //ViewFunc(cab!)
            CreatePopup(cab: cab!,cell: cell , index: index!)
        }
    }
    func ScanCabForSerial(cab : oCabinet , index : Int , cell : TreeViewCell)
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
                    cab.Status = HomeViewController.Status_Cab.connected
                    cab.StatusOld = HomeViewController.Status_Cab.connected
                    
                }
                else if((json as AnyObject).intValue == 2)
                {
                    img = "cabinet_ds"
                    cab.Status = HomeViewController.Status_Cab.connected_DS
                    cab.StatusOld = HomeViewController.Status_Cab.connected_DS
                }
                else
                {
                    img = "cabinet"
                    cab.Status = HomeViewController.Status_Cab.disConnected
                    cab.StatusOld = HomeViewController.Status_Cab.disConnected
                }
                //img = "cabinet"
                HomeViewController.MyVariables.ListAnnotation[index].imageName = img
                
                print("Trang thai ket noi: \(json)")
                semaphore.signal();
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        semaphore.wait(timeout: DispatchTime.distantFuture);
        var sta_cab : String = ""
        if(cab.Status == HomeViewController.Status_Cab.connected)
        {
            sta_cab = "Kết nối - Đèn tắt"
            cell.setTheButtonBackgroundImage(UIImage(named: "cabinet_on")!)
        }
        else if(cab.Status == HomeViewController.Status_Cab.connected_DS)
        {
            sta_cab = "Kết nối - Đèn sáng"
            cell.setTheButtonBackgroundImage(UIImage(named: "cabinet_ds")!)
        }
        else if(cab.Status == HomeViewController.Status_Cab.disConnected)
        {
            sta_cab = "Mất kết nối"
            cell.setTheButtonBackgroundImage(UIImage(named: "cabinet")!)
        }
        presentWindow!.makeToast(message: "Tủ \(cab.CName) - Trạng thái: " + sta_cab)
    }

    
}
