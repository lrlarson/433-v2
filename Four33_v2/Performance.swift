//
//  Performance.swift
//  Four33_v2
//
//  Created by Larry Larson on 2/12/25.
//

import Foundation

// ✅ Wrapper struct for "RECORDINGS" key
struct APIResponse: Codable {
    let RECORDINGS: [Recording]
}

// ✅ Recording Model
struct Recording: Codable, Identifiable {
    let id: String  // ✅ Uses RECORDINGUUID as id
    let dateTimeCreated: String
    let recordist: String
    let title: String
    let geoHash: String
    let inExact: String
    let lat: String  // ✅ Changed from Double to String
    let lon: String  // ✅ Changed from Double to String
    let link: String


    // ✅ Map JSON keys to Swift properties using CodingKeys
    enum CodingKeys: String, CodingKey {
        case id = "RECORDINGUUID"  // ✅ Ensures `id` is set correctly
        case dateTimeCreated = "DATETIMECREATED"
        case recordist = "RECORDIST"
        case title = "TITLE"
        case geoHash = "GEOHASH"
        case inExact = "INEXACT"
        case lat = "LAT"  // ✅ Matches JSON key exactly
        case lon = "LONG" // ✅ Matches JSON key exactly
        case link = "LINK"
    
    }
}
