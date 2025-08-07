//
//  Files.swift
//  Four33_v2
//
//  Created by PKSTONE on 12/10/24.
//

import Foundation

// Caseless enum
enum Files {
    
    static let currentRecordingDirectory = "__current__"
    static let movementNames = ["One", "Two", "Three"]
    static let metadataFilename = "metadata"
    static let audioFileFormatExtension = appConstants.WAV_FORMAT_EXTENSION
    
    enum FilesError: Error {
        case duplicateName
        case createDirectoryFailed
        case deleteFailed
        case getContentsFailed
        case fileDoesNotExist
        case fileCopyFailed
        case fileSaveError
        case cleanupError
        case noMetaDataFound
        case metaDataSaveFailed
    }
    
    static let fileManager = FileManager.default
    
    static func glebba() {
    }
    
    static func clearTempDirectory() throws (FilesError) {
        do {
            let url = getTmpDirURL()
            if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil) {
                while let fileURL = enumerator.nextObject() as? URL {
                    try fileManager.removeItem(at: fileURL)
                }
            }
        }  catch  {
            print(error)
            throw .deleteFailed
        }
    }
    
    
    static func deleteFile(path:String) throws (FilesError) {
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            throw .deleteFailed
        }
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
    }
    
    static func createRecordingDir(pieceName:String) throws (FilesError)
    {
        let piece_dir = getTmpDirURL().appending(path: pieceName)
        if (!fileManager.fileExists(atPath: piece_dir.path())) {
            do {
                try fileManager.createDirectory(at: piece_dir, withIntermediateDirectories: true)
            } catch {
                throw .createDirectoryFailed
            }
        }
    }
    
    // useful for diagnostics
    static func listTmpDir() {
        // list tmp dir contents
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: getTmpDirURL(), includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    files.append(fileURL)
                }
            }
            print(files)
        }
    }
    
    static func loadRecording(name:String) throws (any Error)
    {
        try clearTempDirectory()
        var fromURL: URL!
        if (isSeedRecording(name: name)) {
            fromURL = seedRecordingURL()
        } else {
            fromURL = getDocumentsDirURL().appending(path: name, directoryHint: .isDirectory)
        }
        let toURL = getTmpDirURL().appending(path: name, directoryHint: .isDirectory)
        try fileManager.copyItem(at: fromURL, to: toURL)
        try fileManager.moveItem(at: toURL, to: getTmpDirURL().appending(path: currentRecordingDirectory))
        //listTmpDir()
    }

    // Save the current recording atomically
    //  First, copy the current recording & metadata to the temp directory;
    //   then, edit the (temp) metadata to reflect the new recording name;
    //   finally, move the (temp) recording to the Docs directory.
    static func saveRecording(name:String, metadata:RecordingMetaData) throws (FilesError)
    {
        // Check if a recording of this name already exists
        var isDir: ObjCBool = ObjCBool(true)
        let newRecordingURL = getDocumentsDirURL().appending(path: name, directoryHint: .isDirectory)
        guard !(fileManager.fileExists(atPath: newRecordingURL.path, isDirectory: &isDir) && isDir.boolValue) else {
            throw .duplicateName
        }
        
        // We have a valid recording name:
        // Copy current recording to new folder of that name inside temp directory
        do {
            try createRecordingDir(pieceName: name)
        } catch .createDirectoryFailed {
            throw .createDirectoryFailed
        }
        
        // Copy all three movements
        for mname in movementNames {
            let tmp_url = getTmpDirURL().appending(path: name).appending(path: getMovementFileName(movement: mname))
            let from_url = currentRecordingMovementURL(movement: mname)
            if fileManager.fileExists(atPath: from_url.path()) {
                do {
                    try fileManager.copyItem(at: from_url, to: tmp_url)
                } catch {
                    print (error)
                    throw .fileCopyFailed
                }
            }
        }
        
        // edit metadata to update recording title, then save it to temp recording directory
        var newmeta = RecordingMetaData()
        newmeta.created = metadata.created
        newmeta.geohash = metadata.geohash
        newmeta.title = name
        do {
            try writeMetadataToURL(url: getTmpDirURL().appending(path: name).appending(path:Files.metadataFilename), metadata: newmeta)
        } catch {
            throw .metaDataSaveFailed
        }
        
        // Finally, copy temp recording directory into documents
        // (Any interruption up to this point will leave the recording intact but unsaved)
        do {
            try fileManager.copyItem(at: getTmpDirURL().appending(path: name), to: newRecordingURL)
        } catch {
            print ("Error copying recording to documents. ", error)
            throw .fileSaveError
        }
        
         func cleanOutRecording()
         {
             do {
                 try fileManager.removeItem(at: getTmpDirURL().appending(path: name))
             } catch {
                 print ("Error during temp. directory cleanup: \(error)")
             }

             /*
             [self resetMetadataTitle];
             [self enablePlayButton];       // Actually disables play button because no files exist
             */
             // TODO: Fix this
             //resetPieceToStart()
             //recordingNeedsSaving = NO;
         }

        /*
         // Send "saveSucceeded" event, including saved title
        NSMutableDictionary *extraInfo = [[NSMutableDictionary alloc] init];
        NSString *recordingTitle = name;
        [extraInfo setObject:recordingTitle forKey:@"recordingTitle"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"saveSucceeded"
                                                                object:self
                                                              userInfo:extraInfo];
        });
        //[self refreshSavedRecordingsArray];
        */
    }
    
    
    static func getMovementFileName(movement:String) -> String {
        return String(format:"%@%@%@", "Movement", movement, appConstants.WAV_FORMAT_EXTENSION)
    }
    
    static func getMovementFileNameNoExt(movement:String) -> String {
        return String(format:"%@%@", "Movement", movement)
    }
    
    static func deleteMovement(movement:String) {
        let url = currentRecordingMovementURL(movement:movement)
        if (fileManager.fileExists(atPath: url.path)) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error deleting movement.")
            }
        }
    }
    
    static func deleteMetadata() {
        let url = getCurrentRecordingURL()
            .appending(path: "metadata")
        if (fileManager.fileExists(atPath: url.path)) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error deleting metadata.")
            }
        }
    }
    
    static func performanceExistsSaved(perfName:String) -> Bool {
        let url = getDocumentsDirURL().appending(path: perfName)
        return fileManager.fileExists(atPath: url.path)
    }
    
    static func currentRecordingMovementURL(movement:String) -> URL {
        return getCurrentRecordingURL()
            .appending(path: getMovementFileName(movement: movement))
    }
    
    static func storedPerformanceMovementURL(name:String, movement:String) -> URL {
        return getDocumentsDirURL()
            .appending(path: name, directoryHint: .isDirectory)
            .appending(path: getMovementFileName(movement: movement))
    }
    

    static func buildFullDocsURL(recordingName:String, movement:String) -> URL {
        return getDocumentsDirURL()
            .appending(path: recordingName, directoryHint: .isDirectory)
            .appending(path: getMovementFileName(movement: movement))
    }
    
    static func writeMetadataToURL(url:URL, metadata:RecordingMetaData) throws (FilesError) {
        do {
            let propEncoder = PropertyListEncoder()
            propEncoder.outputFormat = .xml
            let data = try propEncoder.encode(metadata)
            try data.write(to: url)
        } catch {
            print("Error attempting to write recording metadata.")
            print(error);
            throw .fileSaveError
        }
    }
    
    
    static func readMetaDataFromURL(url:URL) -> RecordingMetaData? {
        do {
            let data = try Data(contentsOf: url)
            let mdata = try PropertyListDecoder().decode(RecordingMetaData.self, from: data)
            return mdata
        } catch {
            return nil
        }
    }
    
    // Trim any leading whitespace, and any characters beyond max length
    // called during input of performance name
    static func trimPerfName(name:String) -> String {
        return String(name.drop(while: {$0.isWhitespace}).prefix(appConstants.MAX_RECORDNAME_LENGTH))
    }
    
    
    static func isSeedRecording(name:String) -> Bool {
        return name == appConstants.SEED_RECORDING_DISPLAY_NAME
    }
    
    static func seedRecordingURL() -> URL {
        return Bundle.main.resourceURL!.appending(path:appConstants.SEED_RECORDING, directoryHint: .isDirectory)
    }
    
    
    static func strToDateAndTime(dateStr: String) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = Int(dateStr.prefix(4))
        components.month = Int(dateStr.dropFirst(4).prefix(2))
        components.day = Int(dateStr.dropFirst(6).prefix(2))
        components.hour = Int(dateStr.dropFirst(8).prefix(2))
        components.minute = Int(dateStr.dropFirst(10).prefix(2))
        components.second = Int(dateStr.dropFirst(12).prefix(2))
        if let pdate = calendar.date(from: components) {
            return pdate
        } else {
            return nil
        }
    }
    
    
    static func strToDate(dateStr: String) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = Int(dateStr.prefix(4))
        components.month = Int(dateStr.dropFirst(4).prefix(2))
        components.day = Int(dateStr.dropFirst(6).prefix(2))
        if let pdate = calendar.date(from: components) {
            return pdate
        } else {
            return nil
        }
    }
    
}
