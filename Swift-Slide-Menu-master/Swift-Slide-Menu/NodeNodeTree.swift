//
//  NodeNodeTree.swift
//  Swift-Slide-Menu
//
//  Created by Hung on 12/26/16.
//  Copyright © 2016 Philippe Boisney. All rights reserved.
//
class NodeNodeTree
{
    var tags: String
    var NodeName: String
    var Image: String
    
    
    
    init?(NodeName: String, tags: String,Image : String)
    {
        self.NodeName = NodeName
        self.tags = tags
        self.Image = Image
    }
}


