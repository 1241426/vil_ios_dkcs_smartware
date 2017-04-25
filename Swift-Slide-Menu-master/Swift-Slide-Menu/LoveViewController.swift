//
//  LoveViewController.swift
//  Swift-Slide-Menu
//
//  Created by Philippe Boisney on 05/10/2015.
//  Copyright © 2015 Philippe Boisney. All rights reserved.
//

import UIKit

class LoveViewController: ChildViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var tbView_His: UITableView!
    var type : Int = 0
    
    @IBOutlet weak var lbTuNgayDenNgay: UILabel!
    @IBOutlet weak var txtDenNgay: UITextField!
    @IBOutlet weak var txtDSTu: UITextField!
    @IBOutlet weak var txtTuNgay: UITextField!
    var datePicker : UIDatePicker!
    var datePicker1 : UIDatePicker!
    var to : Int = 0
    var from : Int = 20
    var number = 20
    var startDate : String = "01_02_2017"
    var endDate : String = "01_02_2017"
    var CabIDs : String = "C16176004780,C16176004781"
    
    let textCellIdentifier = "TextCell"
    let swiftBlogs = ["Ray Wenderlich", "NSHipster", "iOS Developer Tips", "Jameson Quave", "Natasha The Robot", "Coding Explorer", "That Thing In Swift", "Andrew Bancroft", "iAchieved.it", "Airspeed Velocity"]
    var slpro:Int = 0
    var ListProblemHistory: Array<oProblemHistory> = Array()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(LoveViewController.refreshList(_:)), name:NSNotification.Name(rawValue: "refresh"), object: nil)
        txtDSTu.addTarget(self, action: #selector(LoveViewController.ViewPopup), for: UIControlEvents.editingDidBegin)
        // Do any additional setup after loading the view.
        tbView_His.register(UITableViewCell.self, forCellReuseIdentifier: textCellIdentifier)
        
        tbView_His.delegate = self
        tbView_His.dataSource = self
        let dateFormatter1 = DateFormatter()
        
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        txtTuNgay.text = dateFormatter1.string(from: Date())
        txtDenNgay.text = dateFormatter1.string(from: Date())
        lbTuNgayDenNgay.text = "Lịch sử sự cố từ ngày " + txtTuNgay.text! + " đến ngày " + txtDenNgay.text!

        ListProblemHistory = Array()
        slpro = 0
        to = 0
        from = 20
        
        
        // ViewPopup()
    }
    func refreshList(_ notification: Notification){
        
        
        lbTuNgayDenNgay.text = "Lịch sử sự cố từ ngày " + txtTuNgay.text! + " đến ngày " + txtDenNgay.text!

        let dstu = PopupCheckbox.PopupVariables.selectedArrayName.componentsJoined(by: ",")
        txtDSTu.text = dstu
        txtDSTu.resignFirstResponder()
        self.ListProblemHistory = Array()
        LoadProblemHistory()
        
    }
    func Run()
    {
        lbTuNgayDenNgay.text = "Lịch sử sự cố từ ngày " + txtTuNgay.text! + " đến ngày " + txtDenNgay.text!
        let dstu = PopupCheckbox.PopupVariables.selectedArrayName.componentsJoined(by: ",")
        txtDSTu.text = dstu
        txtDSTu.resignFirstResponder()
        self.ListProblemHistory = Array()
        LoadProblemHistory()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListProblemHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.text = ListProblemHistory[row].Message + " (" + ListProblemHistory[row].Time + ")"
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
    }
    let threshold = 100.0 // threshold from bottom of tableView
    var isLoadingMore = false // flag
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = Double(scrollView.contentOffset.y)
        let maximumOffset = Double(scrollView.contentSize.height - scrollView.frame.size.height)
        
        if !isLoadingMore && (maximumOffset - contentOffset <= threshold) {
            // Get more data - API call
            
            
            
            self.isLoadingMore = true
            to = from
            from += number
            LoadProblemHistory()
            
        }
    }
    func LoadProblemHistory() {
        
        let scriptUrl = "http://112.213.95.102:1501/android/gethistory"
        let myUrl = URL(string: scriptUrl);
        let session = URLSession.shared
        
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        let dstu = PopupCheckbox.PopupVariables.selectedArray.componentsJoined(by: ",")
        let tungay =  (txtTuNgay.text! as String).replacingOccurrences(of: "/",
                                                                       with: "_",
                                                                       options: NSString.CompareOptions.literal,
                                                                       range: (txtTuNgay.text! as String).startIndex..<(txtTuNgay.text! as String).endIndex)
        let denngay =  (txtDenNgay.text! as String).replacingOccurrences(of: "/",
                                                                         with: "_",
                                                                         options: NSString.CompareOptions.literal,
                                                                         range: (txtDenNgay.text! as String).startIndex..<(txtDenNgay.text! as String).endIndex)
        let postString = "type=" + String(type) + "&startDate=" + tungay + "&endDate=" + denngay + "&to=" + String(to) + "&from=" + String(from) + "&CabIDs=" + dstu
        print(postString)
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        
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
                if let dspro = json as? [[String: AnyObject]] {
                    for pro in dspro {
                        let name: String = (pro["name"] as? String)!
                        let type: String = (pro["type"] as? String)!
                        let typename: String = (pro["typename"] as? String)!
                        let mess: String = (pro["message"] as? String)!
                        let time: String = (pro["time"] as? String)!
                        let pronew : oProblemHistory = oProblemHistory()
                        pronew.Name = name
                        pronew.Type = type
                        pronew.TypeName = typename
                        pronew.Message = mess
                        pronew.Time = time
                        
                        self.ListProblemHistory.append(pronew)
                        //
                    }
                    if(self.slpro == self.ListProblemHistory.count)
                    {
                        self.isLoadingMore = true
                        return
                    }
                    
                    print(self.ListProblemHistory.count)
                    self.slpro = self.ListProblemHistory.count
                    DispatchQueue.main.async {
                        self.tbView_His.reloadData()
                        self.isLoadingMore = false
                        
                    }
                    
                }
                
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
    }
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        self.datePicker.locale = Locale(identifier: "vi")
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoveViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(LoveViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    func ShowPopup()
    {
        
    }
    func pickUpDate1(_ textField : UITextField){
        
        // DatePicker
        self.datePicker1 = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker1.backgroundColor = UIColor.white
        self.datePicker1.datePickerMode = UIDatePickerMode.date
        self.datePicker1.locale = Locale(identifier: "vi")
        textField.inputView = self.datePicker1
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(LoveViewController.doneClick1))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(LoveViewController.cancelClick1))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    func SetTextDsTu(_ dstu:String)
    {
        txtDSTu.text = dstu
    }
    func doneClick() {
        let dateFormatter1 = DateFormatter()
        
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        txtTuNgay.text = dateFormatter1.string(from: datePicker.date)
        txtTuNgay.resignFirstResponder()
        self.Run()
    }
    func cancelClick() {
        txtTuNgay.resignFirstResponder()
    }
    func doneClick1() {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        txtDenNgay.text = dateFormatter1.string(from: datePicker1.date)
        txtDenNgay.resignFirstResponder()
        self.Run()
    }
    func cancelClick1() {
        txtDenNgay.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickUpDate(self.txtTuNgay)
        self.pickUpDate1(self.txtDenNgay)
    }
    func ViewPopup()
    {
        let popupOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "spPopupCheckboxID") as! PopupCheckbox
        self.addChildViewController(popupOverVC)
        popupOverVC.view.frame = self.view.frame
        
        self.view.addSubview(popupOverVC.view)
        popupOverVC.didMove(toParentViewController: self)
        print("Selecetd Array \(PopupCheckbox.PopupVariables.selectedArray)")
    }
    
    
}
