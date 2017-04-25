//
//  TreeViewData.swift
//  TreeView1
//
//  Created by Cindy Oakes on 5/21/16.
//  Copyright © 2016 Cindy Oakes. All rights reserved.
//

class TreeViewData
{
    var level: Int
    var name: String
    var id: String
    var parentId: String
    
    init?(level: Int, name: String, id: String, parentId: String)
    {
        self.level = level
        self.name = name
        self.id = id
        self.parentId = parentId
    }
}


