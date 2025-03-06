//
//  RecordingMetaData.swift
//  Four33_v2
//
//  Created by PKSTONE on 3/5/25.
//

import Foundation

struct RecordingMetaData: Codable {
    var created: String
    var geohash: String
    var title: String
    init() {
        created = ""
        geohash = appConstants.LOCATION_NOT_RECORDED
        title = ""
    }
}
