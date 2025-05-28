//
//  ContentView.swift
//  Four33_v2
//
//  Created by PKSTONE on 10/19/24.
//

struct appConstants {
    static let MVI_DURATION =  30.0
    static let MVII_DURATION = 143.0
    static let MVIII_DURATION = 100.0
    static let INTER_MOVEMENT_DURATION = 10.0

    static let TIMER_GRAIN = 0.25
    
    static let MAX_RECORDNAME_LENGTH = 20
    static let MAX_RECORDIST_NAME_LENGTH = 20

    static let AAC_FORMAT_EXTENSION = ".m4a"
    static let UNIFIED_FILE_NAME = "4_33"
    static let WAV_FORMAT_EXTENSION = ".wav"

    static let LOCATION_NOT_RECORDED = "not recorded"
    static let NO_LOCATION_DEGREES = -9999.0

    static let BLUE_FOR_LOGO = "007AFF"
    
    static let SEED_RECORDING = "Seed_Recording"
    static let SEED_RECORDING_DATE = "20131107"
    static let SEED_RECORDING_DISPLAY_NAME = "Cage\'s NYC Apartment"

    // The geohash part of the UID has this much resolution (7 = neighborhood level)
    static let GEOHASH_DIGITS_FOR_UID  = 7
    static let GEOHASH_DIGITS_HI_ACCURACY = 12

    static let S3_BUCKET_NAME = "john_cage_433"
    static let AUDIO_FILE_URL_HEAD = "https://s3.amazonaws.com/john_cage_433/"
    static let CAGE_TVM_URL = "cagetvm2.elasticbeanstalk.com"

    static let CAGE_METADATA_UP_JSON = "app/cageJSON.cfc"
    static let CAGE_JSON_URL = "https://johncage.org/cageJSON.cfc"
    static let CAGE_JSON_PARM_PREFIX_WHOLE_WORLD = "?method=getUploadedRecordings2&returnFormat=JSON"
    static let CAGE_JSON_PARM_PREFIX_FILTERED = "?method=getUploadedRecordings3&returnFormat=JSON"

    // For setting map spans:
    static let METERS_PER_MILE = 1609.344
}

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            Tab("Record and Play", systemImage: "mic.fill") {
                RecordPlayView()
            }
            Tab("Library", systemImage: "folder.fill") {
                LibraryView()
            }
            Tab("World of 4'33", systemImage: "globe") {
                WorldView()
            }
            Tab("Info", systemImage: "info.circle.fill") {
                InfoView()
            }
        }
    }
}

#Preview {
    ContentView()
}
