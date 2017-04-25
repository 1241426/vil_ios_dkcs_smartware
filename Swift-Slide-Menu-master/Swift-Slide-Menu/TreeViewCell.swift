//
//  TreeViewCell.swift
//  TreeView1
//
//  Created by Cindy Oakes on 5/19/16.
//  Copyright © 2016 Cindy Oakes. All rights reserved.
//

import UIKit


class TreeViewCell: UITableViewCell
{
    
    //MARK:  Properties & Variables

    @IBOutlet weak var treeButton: UIButton!
    @IBOutlet weak var treeLabel: UILabel!
    var treeNode: TreeViewNode!
    
    
    //MARK:  Draw Rectangle for Image
    
    override func draw(_ rect: CGRect) {
        var cellFrame: CGRect = self.treeLabel.frame
        var buttonFrame: CGRect = self.treeButton.frame
        let indentation: Int = self.treeNode.nodeLevel! * 25
        cellFrame.origin.x = buttonFrame.size.width + CGFloat(indentation) + 5
        buttonFrame.origin.x = 2 + CGFloat(indentation)
        self.treeLabel.frame = cellFrame
        self.treeButton.frame = buttonFrame
    }
    
    //MARK:  Set Background image
    
    func setTheButtonBackgroundImage(_ backgroundImage: UIImage)
    {
        self.treeButton.setBackgroundImage(backgroundImage, for: UIControlState())
    }
    
    //MARK:  Expand Node
    
    @IBAction func expand(_ sender: AnyObject)
    {
        if (self.treeNode != nil)
        {
            if self.treeNode.nodeChildren != nil
            {
                if self.treeNode.isExpanded == GlobalVariables.TRUE
                {
                    self.treeNode.isExpanded = GlobalVariables.FALSE
                }
                else
                {
                    self.treeNode.isExpanded = GlobalVariables.TRUE
                }
            }
            else
            {
                self.treeNode.isExpanded = GlobalVariables.FALSE
            }
            
            self.isSelected = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "TreeNodeButtonClicked"), object: self)
            //print("button clicked")
        }
    }
}
