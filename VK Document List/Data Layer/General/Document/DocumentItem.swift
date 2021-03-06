//
//  DocumentItem.swift
//  VK Document List
//
//  Created by Vladislav on 23.02.2020.
//  Copyright © 2020 Vladislav Markov. All rights reserved.
//

import Foundation

struct DocumentItem {
    
    // MARK: - Props
    var id: Int
    var ownerId: Int
    var title: String
    var ext: String
    var url: String
    var date: Date
    var type: DocumentItemType
    
}
