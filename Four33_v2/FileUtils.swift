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
    
    struct RecordingMetaData: Codable {
        var created: String
        var geohash: String
        var title: String
    }
    
    /* Formerly:
     - (void)writeMetadataToPath: (NSString *)path WithDictionary: (NSMutableDictionary *)metadata
     
     url: path including the piece name and metadata filename
     */
    static func writeMetadataToURL(url:URL, metadata:RecordingMetaData) -> Bool {
        do {
            let propEncoder = PropertyListEncoder()
            propEncoder.outputFormat = .xml
            let data = try propEncoder.encode(metadata)
            try data.write(to: url)
        } catch {
            print("Error attempting to write recording metadata.")
            print(error);
            return false
        }
        return true
    }
    
    
    /* Formerly:
     - (NSMutableDictionary *)readMetaDataFromPath: (NSString *)path

     url: path including the piece name and metadata filename
     */

    static func readMetaDataFromURL(url:URL) -> RecordingMetaData? {
        do {
            let data = try Data(contentsOf: url)
            let mdata = try PropertyListDecoder().decode(RecordingMetaData.self, from: data)
            return mdata
        } catch {
            print("Error attempting to read recording metadata.")
            return nil
        }
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


func copyFilesFromBundleToDocumentsFolderWith(fileExtension: String) {
    if let resPath = Bundle.main.resourcePath {
        do {
            let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
            for fileName in filteredFiles {
                if let documentsURL = documentsURL {
                    let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                    let destURL = documentsURL.appendingPathComponent(fileName)
                    do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                }
            }
        } catch { }
    }
}
