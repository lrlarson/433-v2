//
//  Performance.swift
//  Four33_v2
//
//  Created by Larry Larson on 2/12/25.
//

import Foundation

struct Performance:Codable, Identifiable {
    let RECORDINGUUID: String
    let DATETIMECREATED: String
    let RECORDIST: String
    let GEOHASH: String
    let INEXACT: String
    let LAT:Double
    let LON:Double
    
    var id: String { RECORDINGUUID }  // Define `id` to conform to Identifiable
}
