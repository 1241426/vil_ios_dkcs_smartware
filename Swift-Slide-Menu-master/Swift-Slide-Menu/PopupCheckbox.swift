//
//  PopupCheckbox.swift
//  Swift-Slide-Menu
//
//  Created by Hung on 2/10/17.
//  Copyright © 2017 Philippe Boisney. All rights reserved.
//

import UIKit
class PopupCheckbox: UIViewController, UITableViewDelegate, UITableViewDataSource  {
  
   // var numberArray = NSMutableArray()
    @IBAction func OK(_ sender: Any) {
        RemoveAnimate()
    }
    @IBAction func Close(_ sender: AnyObject) {
        RemoveAnimate()
    }
    var ListCabinetForUser : Array<oItemCheck> = Array()
    struct PopupVariables{
        
        static  var selectedArray=NSMutableArray()
        static  var selectedArrayName=NSMutableArray()
    }
    @IBOutlet weak var tbListViewCheckbox: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        ShowAnimate()
        let checkall : oItemCheck = oItemCheck()
        checkall.CID = "-1"
        checkall.CName = "Chọn tất cả"
        ListCabinetForUser.append(checkall)
        for index in 0...HomeViewController.MyVariables.ListCabinet.count - 1 {
            
            //numberArray.addObject(index)
            let check : oItemCheck = oItemCheck()
            check.CID = HomeViewController.MyVariables.ListCabinet[index].CID
            check.CName = HomeViewController.MyVariables.ListCabinet[index].CName
            ListCabinetForUser.append(check)
        }
        tbListViewCheckbox.delegate = self
        tbListViewCheckbox.dataSource = self
    }
    func ShowAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func RemoveAnimate() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
        UIView.animate(withDuration: 0.25, animations: {self.view.alpha = 0.0
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            },completion: {
                (finished:Bool) in if(finished){ self.view.removeFromSuperview()}
        })
        
    }
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /////NUMBER OF ROWS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ListCabinetForUser.count;
        
    }
    func SetCheckAllItem(_ currentCell:CustomItemListView,index:Int)
    {
       
        if(flagCheckAll)
        {
            if !PopupVariables.selectedArray.contains(ListCabinetForUser[index].CID)
            {
                PopupVariables.selectedArray.add(ListCabinetForUser[index].CID)
                PopupVariables.selectedArrayName.add(ListCabinetForUser[index].CName)
                currentCell.btnCheckbox.setBackgroundImage(UIImage(named:"Check"), for:    UIControlState())
                
            }
            
        }
        else
        {
            if PopupVariables.selectedArray.contains(ListCabinetForUser[index].CID)
            {
                PopupVariables.selectedArray.remove(ListCabinetForUser[index].CID)
                PopupVariables.selectedArrayName.remove(ListCabinetForUser[index].CName)
                currentCell.btnCheckbox.setBackgroundImage(UIImage(named:"Uncheck"), for:    UIControlState())
                
            }
        }

    }
    func setCheckItem(_ currentCell:CustomItemListView,index:Int)
    {
        print(index)
        tickClicked(index)
        ListCabinetForUser[index].flag = true
        if PopupVariables.selectedArray .contains(ListCabinetForUser[index].CID) {
            currentCell.btnCheckbox.setBackgroundImage(UIImage(named:"Check"), for:    UIControlState())
        }
        else
        {
            currentCell.btnCheckbox.setBackgroundImage(UIImage(named:"Uncheck"), for: UIControlState())
        }

    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let lastRow = (tableView.indexPathsForVisibleRows?.last)! as NSIndexPath
//        if indexPath.row == lastRow.row {
//            if(ListCabinetForUser[indexPath.row].flag)
//            {return}
//            if(flagCheckAll)
//            {
//                if !selectedArray.containsObject(ListCabinetForUser[indexPath.row].CID)
//                {
//                    selectedArray.addObject(ListCabinetForUser[indexPath.row].CID)
//                    let cell1 = cell as! CustomItemListView
//                    cell1.btnCheckbox.setBackgroundImage(UIImage(named:"Check"), forState:    UIControlState.Normal)
//
//                }
//
//            }
//            else
//            {
//                if selectedArray.containsObject(ListCabinetForUser[indexPath.row].CID)
//                {
//                    selectedArray.removeObject(ListCabinetForUser[indexPath.row].CID)
//                    let cell1 = cell as! CustomItemListView
//                    cell1.btnCheckbox.setBackgroundImage(UIImage(named:"Uncheck"), forState:    UIControlState.Normal)
//                    
//                }
//            }
//            print(String(indexPath.row))
//        }
    }
    var flagCheckAll : Bool = false
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            let indexPath = tableView.indexPathForSelectedRow! //optional, to get from any UIButton for example
            let currentCell = tableView.cellForRow(at: indexPath)! as! CustomItemListView
            setCheckItem(currentCell,index: indexPath.row)
            if(indexPath.row == 0)
            {
                flagCheckAll = !flagCheckAll
                for index in 1...HomeViewController.MyVariables.ListCabinet.count {
                    let path = IndexPath(row: index, section: 0)
                    let currentCell1 = tableView.dequeueReusableCell(withIdentifier: "reuseCell", for: path) as! CustomItemListView
                    //let currentCell1 = tableView.cellForRowAtIndexPath(path)! as! CustomItemListView
                    SetCheckAllItem(currentCell1,index: path.row)
                }
            }

        } catch {
            //print("error serializing JSON: \(error)")
        }
        
    }
    /////CELL FOR ROW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let contact = ListCabinetForUser[indexPath.row].CName
        let cell:CustomItemListView = tbListViewCheckbox.dequeueReusableCell(withIdentifier: "reuseCell") as! CustomItemListView
        
        cell.textLabel?.text = contact
        
        
//        cell.btnCheckbox.addTarget(self, action:#selector(PopupCheckbox.tickClicked1(_:)), for: .touchUpInside)
//        
        cell.btnCheckbox.tag=indexPath.row
        
        if PopupVariables.selectedArray.contains(ListCabinetForUser[indexPath.row].CID) {
            cell.btnCheckbox.setBackgroundImage(UIImage(named:"Check"), for: UIControlState())
        }
        else
        {
            cell.btnCheckbox.setBackgroundImage(UIImage(named:"Uncheck"), for: UIControlState())
        }
        return cell
    }
    /////HEIGHT FOR ROW
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->CGFloat
    {
        return 80.0
    }
    func tickClicked(_ value:Int)//sender: UIButton!
    {
//        let value = sender.tag;
//        print("value=" + String(value))
        if PopupVariables.selectedArray.contains(ListCabinetForUser[value].CID)
        {
            PopupVariables.selectedArray.remove(ListCabinetForUser[value].CID)
             PopupVariables.selectedArrayName.remove(ListCabinetForUser[value].CName)
        }
        else
        {
            PopupVariables.selectedArray.add(ListCabinetForUser[value].CID)
            PopupVariables.selectedArrayName.add(ListCabinetForUser[value].CName)
        }
        
        print("Selecetd Array \(PopupVariables.selectedArray)")
        
        tbListViewCheckbox.reloadData()
        
    }
    func tickClicked1(_ sender: UIButton!)
    {
                let value = sender.tag;
        if PopupVariables.selectedArray.contains(ListCabinetForUser[value].CID)
        {
            PopupVariables.selectedArray.remove(ListCabinetForUser[value].CID)
            PopupVariables.selectedArrayName.remove(ListCabinetForUser[value].CName)
        }
        else
        {
            PopupVariables.selectedArray.add(ListCabinetForUser[value].CID)
            PopupVariables.selectedArrayName.add(ListCabinetForUser[value].CName)
        }
        
        print("Selecetd Array \(PopupVariables.selectedArray)")
        
        tbListViewCheckbox.reloadData()
        
    }

   
}
