//
//  FileUtils.swift
//  Four33_v2
//
//  Created by PKSTONE on 12/10/24.
//

import Foundation

// Caseless enum
enum FileUtils {
    
    static let currentRecordingDirectory = "__current__"
    static let movementNames = ["One", "Two", "Three"]
    static let metadataFilename = "metadata"
    static let audioFileFormatExtension = appConstants.WAV_FORMAT_EXTENSION
    
    static let fileManager = FileManager.default
    
    static func clearTempDirectory() -> Bool {
        var directoryContents: [URL]
        let tempDir:URL = getTmpDirURL()
        do {
            directoryContents = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        } catch {
            print("Error getting contents of temp directory.")
            return false
        }
        for t_url in directoryContents {
            let newURL:URL = tempDir.appending(path:t_url.path())
            do {
                try fileManager.removeItem(at:newURL)
            } catch {
                print("Error while deleting items from temp directory.")
                return false
            }
        }
        return true
    }
     
    
    static func deleteFile(path:String) -> Bool {
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            print("Error attempting to delete file '", path, "'.")
            return false
        }
        return true
    }
    
    static func getDocumentsDirURL() -> URL {
        return  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func getTmpDirURL() -> URL {
        return  fileManager.temporaryDirectory
    }
        
    static func getCurrentRecordingURL() -> URL {
        return getTmpDirURL().appending(path: currentRecordingDirectory)
    }
        
    static func createRecordingDir(url:URL) -> Bool {
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
        } catch {
            print("Error attempting to create temp. recording directory.")
            return false
        }
        return true
    }
    
    
    /* Formerly:
     - (NSString *) buildFullPathFromOuterDirectory:
     
     Use buildFullDocsURL, below
    
    static func buildTempRecordingDirFileURL(recordingName:String,
                                                filename:String) -> URL {
        return getTmpDirectory().appending(path: recordingName, directoryHint: .isDirectory).appending(path: filename)
    }
    */

    
    static func getMovementFileName(movement:String) -> String {
        return String(format:"%@%@%@", "Movement", movement, appConstants.WAV_FORMAT_EXTENSION)
    }
    
    static func getMovementFileNameNoExt(movement:String) -> String {
        return String(format:"%@%@", "Movement", movement)
    }
    
    
    /* Formerly:
     - (NSString *) buildRecordPathWithMovementName: (NSString *)movement
     */
    static func buildFullTempURL(movement:String) -> URL {
        return getCurrentRecordingURL()
            .appending(path: getMovementFileName(movement: movement))
    }
    
        
    /* Formerly:
     - (NSString *) buildPathWithDocumentsSubDir
     Also replaces buildFullPathFromOuterDirectory
    */
    static func buildFullDocsURL(recordingName:String, movement:String) -> URL {
        return getDocumentsDirURL()
            .appending(path: recordingName, directoryHint: .isDirectory)
            .appending(path: getMovementFileName(movement: movement))
    }
    
    struct RecordingMetaData: Decodable {
        let container: Dictionary<String, String>
    }
    
    /* Formerly:
     - (void)writeMetadataToPath: (NSString *)path WithDictionary: (NSMutableDictionary *)metadata
     
     url: path including the piece name
     */
    static func writeMetadataToURL(url:URL, metadata:Dictionary<String, String>) -> Bool {
        let meta_url = url.appending(path: metadataFilename)
        do {
            let data = try PropertyListEncoder().encode(metadata)
            try data.write(to: meta_url)
        } catch {
            print("Error attempting to write recording metadata.")
            return false
        }
        return true
    }
    
    
    /* Formerly:
     - (NSMutableDictionary *)readMetaDataFromPath: (NSString *)path
     */

    static func readMetaDataFromPath(url:URL) -> Dictionary<String, String> {
        let meta_url = url.appending(path: metadataFilename)
        let dictionary:[String:String] = ["":""]
        do {
            let data = try Data(contentsOf: meta_url)
            let dictionary = try PropertyListDecoder().decode(RecordingMetaData.self, from: data)
        } catch {
            print("Error attempting to read recording metadata.")
            print(error)
        }
        return dictionary
    }
    

       
    /*
     - (NSMutableDictionary *)readMetaDataFromFullPath:(NSString *)fullPath
     {
     NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
     // Clean out obsolete metadata entries
     [metadata removeObjectForKey:@"location"];
     [metadata removeObjectForKey:@"recordist"];
     return metadata;
     }
     
     */
}
