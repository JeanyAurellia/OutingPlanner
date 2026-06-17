//
//  Item.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 17/06/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
