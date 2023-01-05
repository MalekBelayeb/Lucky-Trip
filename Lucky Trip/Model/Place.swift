//
//  Place.swift
//  Lucky Trip
//
//  Created by odc on 5/1/2023.
//

import Foundation

struct Place {
    
    var xid : String?
    var name : String
    var dist : Double
    var address: Address?
    var kinds : String?
    var wikipedia: String?
    var image: String?
    var wikipediaExtracts: WikipediaExtracts?
    var point : CGPoint
}
