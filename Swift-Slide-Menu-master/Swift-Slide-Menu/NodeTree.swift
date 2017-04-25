//
//  NodeTree.swift
//  Swift-Slide-Menu
//
//  Created by Hung on 12/26/16.
//  Copyright © 2016 Philippe Boisney. All rights reserved.
//

class NodeTree
{
    var tags: String
    var NodeName: String
    var ListNode :Array<NodeTree>
    var Image: String
    var CID : String
    var SLTu:Int
    
    init?(NodeName: String, tags: String,Image : String,ListNode:Array<NodeTree>,CID: String,SLTu:Int)
    {
        self.NodeName = NodeName
        self.tags = tags
        self.Image = Image
        self.ListNode = ListNode
        self.CID = CID
        self.SLTu = SLTu
    }
}

