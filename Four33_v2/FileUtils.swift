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
        let tempDir:URL = getTmpDirectory()
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
    
    static func getDocumentsDirectory() -> URL {
        return  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func getTmpDirectory() -> URL {
        return  fileManager.temporaryDirectory
    }
        
    static func getCurrentRecordingDirectory() -> URL {
        return getTmpDirectory().appending(path: currentRecordingDirectory)
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
    
    static func buildFullPathFromOuterDirectory(outerDirectory:String,
                                                recordingName:String,
                                                filename:String) -> String {
        return ""
    }
    
    /*
     - (NSString *) buildFullPathFromOuterDirectory: (NSString *)outerDirectory
     withRecordingName: (NSString *)recordingName
     filename: (NSString *)filename
     {
     return [[outerDirectory stringByAppendingPathComponent:recordingName] stringByAppendingPathComponent:filename];
     }
     
     */
    
    static func getPathToDocumentsDir() -> String {
        return ""
    }
    
    /*
     - (NSString *) getPathToDocumentsDir
     {
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
     NSUserDomainMask, YES);
     return [paths objectAtIndex:0];
     }
     
     */
    
    static func buildPathToDocumentsSubdir(dirName:String) -> String {
        return ""
    }
    
    /*
     - (NSString *) buildPathToDocumentsSubdir: (NSString *)dirName;
     {
     return [[self getPathToDocumentsDir] stringByAppendingPathComponent: dirName];
     }
     
     */
    
    static func getMovementFileName(movement:String) -> String {
        return ""
    }
    
    /*
     - (NSString *) getMovementFileName: (NSString *)movement
     {
     return [NSString stringWithFormat:@"%@%@%@", @"Movement", movement, audioFormatFileExtension];
     }
     
     */
    
    static func getMovementFileNameNoExt(movement:String) -> String {
        return ""
    }
    
    /*
     - (NSString *) getMovementFileNameNoExt: (NSString *)movement
     {
     return [NSString stringWithFormat:@"%@%@", @"Movement", movement];
     }
     
     */
    
    static func buildRecordPathWithMovementName(movement:String) -> String {
        return ""
    }
    
    /*
     - (NSString *) buildRecordPathWithMovementName: (NSString *)movement
     {
     
     return [[self getCurrentRecordingDirFullPath]
     stringByAppendingPathComponent:[self getMovementFileName:movement]];
     }
     
     */
    
    static func buildPathWithDocumentsSubDir(subDirName:String, movement:String) -> String {
        return ""
    }
    
    /*
     - (NSString *) buildPathWithDocumentsSubDir: (NSString *)subDirName
     MovementName: (NSString *)movement
     {
     return [[self buildPathToDocumentsSubdir: subDirName]
     stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@",
     @"Movement", movement,
     audioFormatFileExtension]];
     }
     
     */
    
    static func writeMetadataToPath(path:String, metadata:String) -> String {
        return ""
    }
    
    /*
     - (void)writeMetadataToPath: (NSString *)path WithDictionary: (NSMutableDictionary *)metadata
     {
     NSString *fullpath = [path stringByAppendingPathComponent:[self metadataFilename]];
     BOOL success = [metadata writeToFile:fullpath atomically:YES];
     if (!success) {
     NSLog(@"Error writing metadata file.");
     }
     }
     
     */
    
    static func readMetaDataFromPath(path:String) -> String {
        return ""
    }
    
    /*
     - (NSMutableDictionary *)readMetaDataFromPath: (NSString *)path
     {
     NSString *metafilepath = [path stringByAppendingPathComponent:[self metadataFilename]];
     return [self readMetaDataFromFullPath:metafilepath];
     }
     
     */
    
    static func readMetaDataFromFullPath(path:String) -> String {
        return ""
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
