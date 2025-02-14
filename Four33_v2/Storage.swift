//
//  Storage.swift
//  Four33_v2
//
//  Created by PKSTONE on 12/10/24.
//

import Foundation

// Caseless enum
enum Storage {
    
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
        // Do recording and playback in temp directory
        return getTmpDirURL().appending(path: currentRecordingDirectory)
        
        // During development, do temp work in user folder so it can be seen
        //return getDocumentsDirURL().appending(path: currentRecordingDirectory)
    }
        
    static func createRecordingDir() -> Bool {
        if (!fileManager.fileExists(atPath: getCurrentRecordingURL().path)) {
            do {
                try fileManager.createDirectory(at: getCurrentRecordingURL(), withIntermediateDirectories: false)
            } catch {
                print("Error attempting to create temp. recording directory.")
                return false
            }
            return true
        }
        return true
    }
    
    // Save the current recording atomically (as possible)*:
    //  First, copy the current recording & metadata to the temp directory;
    //   then, edit the (temp) metadata to reflect the new recording name;
    //   finally, move the (temp) recording to the Docs directory.
    //
    //   * Even more finally (this is the part that is not completely atomic), notify the
    //   RecordPlayController to update the current recording's name. In the worst case,
    //   a save interrupted just at this point might mean the displayed recording name
    //   is not updated properly.
    func saveRecording(name:String)
    {
        // Check if a recording of this name already exists
        let newRecordingURL = Storage.getDocumentsDirURL().appending(path: name, directoryHint: .isDirectory)
        //let tempRecordingPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
        
        if (Storage.fileManager.fileExists(atPath: newRecordingURL.path)) {
        }
        
        /*
        if ([[NSFileManager defaultManager] fileExistsAtPath:docsRecordingPath])
        {
            [self saveFailedWithReason:@"duplicate name"];
            return;
        }
        
        // We have a valid recording name:
        
        // Copy current recording to new folder of that name inside temp directory
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:tempRecordingPath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            [self saveFailedWithReason:@"create directory failed"];
            return;
        }
        // Copy all three movements
        NSString *fromFile, *newFile;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        for (NSString *mname in [fileUtils movementNames]) {
            fromFile = [fileUtils buildRecordPathWithMovementName:mname];
            if ([fileMgr fileExistsAtPath:fromFile]) {
                newFile = [tempRecordingPath stringByAppendingPathComponent:[fileUtils getMovementFileName:mname]];
                if (![fileMgr copyItemAtPath:fromFile toPath:newFile error:&error]) {
                    [self saveFailedWithReason:@"file copy failed"];
                    return;
                }
            }
        }
        
        // Load, then edit metadata to update recording title, then save it to temp recording directory
        NSMutableDictionary *metadata = [fileUtils readMetaDataFromPath:
                                         [fileUtils getCurrentRecordingDirFullPath]];
        [metadata setValue:name forKey:@"title"];
        [fileUtils writeMetadataToPath:tempRecordingPath WithDictionary:metadata];
        
        // Finally, move temp recording directory into documents
        // (Any interruption up to this point will leave the recording intact but unsaved)
        if (![fileMgr moveItemAtPath:tempRecordingPath toPath:docsRecordingPath error:&error]) {
            // Error while moving recording to docs directory
            [self saveFailedWithReason:@"file move failed"];
            return;
        }
        
        // Delete recording from temp directory
        [fileMgr removeItemAtPath:tempRecordingPath error:nil];
        
        // Send "saveSucceeded" event, including saved title
        NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] init];
        NSString *recordingTitle = name;
        [extraInfo setObject:recordingTitle forKey:@"recordingTitle"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"saveSucceeded"
                                                                object:self
                                                              userInfo:extraInfo];
        });
        [self refreshSavedRecordingsArray];
         */
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
    
    static func deleteMovement(movement:String) {
        let url = buildFullTempURL(movement:movement)
        if (fileManager.fileExists(atPath: url.path)) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error deleting movement.")
            }
        }
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


func copyStorageFromBundleToDocumentsFolderWith(fileExtension: String) {
    if let resPath = Bundle.main.resourcePath {
        do {
            let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let filteredStorage = dirContents.filter{ $0.contains(fileExtension)}
            for fileName in filteredStorage {
                if let documentsURL = documentsURL {
                    let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                    let destURL = documentsURL.appendingPathComponent(fileName)
                    do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                }
            }
        } catch { }
    }
}
