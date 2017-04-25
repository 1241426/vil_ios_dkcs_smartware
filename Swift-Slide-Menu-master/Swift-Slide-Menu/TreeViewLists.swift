//
//  TreeViewLists.swift
//  TreeView1
//
//  Created by Cindy Oakes on 5/21/16.
//  Copyright © 2016 Cindy Oakes. All rights reserved.
//
import UIKit
class TreeViewLists
{
    //MARK:  Load Array With Initial Data 
    
    static func LoadInitialData(_ ListQuan : Array<NodeTree>) -> [TreeViewData]
    {
        var data: [TreeViewData] = []
        
        for i in 0...ListQuan.count - 1 {
            let NodeQuan:NodeTree = (ListQuan[i]  as? NodeTree)!
            data.append(TreeViewData(level: 0, name:NodeQuan.NodeName, id: NodeQuan.CID, parentId: "-1")!)
            for j in 0...NodeQuan.ListNode.count - 1 {
                let NodeDuong:NodeTree = (NodeQuan.ListNode[j] as? NodeTree)!
                data.append(TreeViewData(level: 1, name: NodeDuong.NodeName, id: NodeDuong.CID, parentId: NodeQuan.CID)!)
                for k in 0...NodeDuong.ListNode.count - 1 {
                    let NodeTu:NodeTree = (NodeDuong.ListNode[k] as? NodeTree)!
                    data.append(TreeViewData(level: 2, name: NodeTu.NodeName, id: NodeTu.CID, parentId: NodeDuong.CID)!)
                }
            }
        }
        
        
        
        
//        data.append(TreeViewData(level: 0, name: "cindy's family tree", id: "1", parentId: "-1")!)
//        data.append(TreeViewData(level: 0, name: "jack's family tree", id: "2", parentId: "-1")!)
//        data.append(TreeViewData(level: 1, name: "katherine", id: "3", parentId: "1")!)
//        data.append(TreeViewData(level: 1, name: "kyle", id: "4", parentId: "1")!)
//        data.append(TreeViewData(level: 2, name: "hayley", id: "5", parentId: "3")!)
//        data.append(TreeViewData(level: 2, name: "macey", id: "6", parentId: "3")!)
//        data.append(TreeViewData(level: 1, name: "katelyn", id: "7", parentId: "2")!)
//        data.append(TreeViewData(level: 1, name: "jared", id: "8", parentId: "2")!)
//        data.append(TreeViewData(level: 1, name: "denyee", id: "9", parentId: "2")!)
//        data.append(TreeViewData(level: 2, name: "cayleb", id: "10", parentId: "4")!)
//        data.append(TreeViewData(level: 2, name: "carter", id: "11", parentId: "4")!)
//        data.append(TreeViewData(level: 2, name: "braylon", id: "12", parentId: "4")!)
//        data.append(TreeViewData(level: 3, name: "samson", id: "13", parentId: "5")!)
//        data.append(TreeViewData(level: 3, name: "samson", id: "14", parentId: "6")!)

        
        return data
    }
   
    
    //MARK:  Load Nodes From Initial Data
    
    static func LoadInitialNodes(_ dataList: [TreeViewData]) -> [TreeViewNode]
    {
        var nodes: [TreeViewNode] = []
        
        for data in dataList where data.level == 0
        {
            
            
            let node: TreeViewNode = TreeViewNode()
            node.nodeLevel = data.level
            node.nodeObject = data.name as AnyObject?
            node.isExpanded = GlobalVariables.TRUE
            node.CID = data.id
            let newLevel = data.level + 1
            node.nodeChildren = LoadChildrenNodes(dataList, level: newLevel, parentId: data.id)
            
            if (node.nodeChildren?.count == 0)
            {
                node.nodeChildren = nil
            }
            
            nodes.append(node)
         
        }
        
        return nodes
    }
    
    //MARK:  Recursive Method to Create the Children/Grandchildren....  node arrays
    
    static func LoadChildrenNodes(_ dataList: [TreeViewData], level: Int, parentId: String) -> [TreeViewNode]
    {
        var nodes: [TreeViewNode] = []
        
        for data in dataList where data.level == level && data.parentId == parentId
        {
           
            
            let node: TreeViewNode = TreeViewNode()
            node.nodeLevel = data.level
            node.nodeObject = data.name as AnyObject?
            node.isExpanded = GlobalVariables.TRUE
            node.CID = data.id
            let newLevel = level + 1
            node.nodeChildren = LoadChildrenNodes(dataList, level: newLevel, parentId: data.id)
            
            if (node.nodeChildren?.count == 0)
            {
                node.nodeChildren = nil
                node.isChildren = 1
            }
            
            nodes.append(node)
            
        }
        
        return nodes
    }
    
    
}
