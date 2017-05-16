//
//  Parser.swift
//  SplashBuddy
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Foundation

class FileWatcher {
    // TODO: optimize the reader not to read the whole file every time
    var fd: FileHandle
    var lastLineRead: Int
    init (fd: FileHandle) {
        self.fd = fd
        self.lastLineRead = -1
    }
    func readRemaining() -> [String] {
        var ret = [String]()
        guard let lines = fd.readLines() else {
            return ret
        }
        for i in (self.lastLineRead+1)..<lines.count {
            ret.append(lines[i])
        }
        self.lastLineRead = lines.count - 1
        return ret
    }
}

class BaseParser {
    var fileWatcher: FileWatcher
    init (fd: FileHandle) {
        self.fileWatcher = FileWatcher(fd: fd)
    }
    func parse() {
        let lines = fileWatcher.readRemaining()
        parse(lines: lines)
    }
    internal func parse(lines: [String]) {
        
    }
}

class JamfParser: BaseParser {
    
    
    override internal func parse(lines: [String]) {
        DispatchQueue.global(qos: .background).async {
            var name: String?
            var version: String?
            var status: Software.SoftwareStatus?
            
            for line in lines {
                let statusAndRegExDict = initRegex()
                for (regexStatus, regex) in statusAndRegExDict {
                    
                    status = regexStatus
                    
                    let matches = regex!.matches(in: line, options: [], range: NSMakeRange(0, line.characters.count))
                    
                    if !matches.isEmpty {
                        name = (line as NSString).substring(with: matches[0].rangeAt(1))
                        version = (line as NSString).substring(with: matches[0].rangeAt(2))
                        break
                    }
                }
                if let packageName = name, let packageVersion = version, let packageStatus = status {
                    let software = Software(packageName: packageName, version: packageVersion, status: packageStatus)
                    DispatchQueue.main.async {
                        SoftwareArray.sharedInstance.array.modify(with: software)
                    }
                }
            }
        }
    }
}

class FWParser: BaseParser {
    override internal func parse(lines: [String]) {
        var objs = [Software]()
        
        // TODO: FW parsing code
        
        
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                SoftwareArray.sharedInstance.array.modify(with: objs)
            }
        }
    }
}


class Parser: NSObject {
    static let sharedInstance = Parser()
    var jamfParser: JamfParser?
    var fwParser: FWParser?
    
    override init() {
        if let fd = Preferences.sharedInstance.logFileHandle {
            jamfParser = JamfParser(fd: fd)
        }
        if let fd = Preferences.sharedInstance.logFileHandleForFW {
            fwParser = FWParser(fd: fd)
        }
        super.init()
        
    }
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: false)
    }
    func onTimer() {
        jamfParser!.parse()
        fwParser!.parse()
    }
    
//    override init() {
//        super.init()
//        
//        // Setup Timer to parse log
//        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimer), userInfo: nil, repeats: true)
//        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(readTimerForFW), userInfo: nil, repeats: false)
//        
//    }
//    
//    func readTimer() -> Void {
//        
//        DispatchQueue.global(qos: .background).async {
//            
//            guard let logFileHandle = Preferences.sharedInstance.logFileHandle else {
//                // Hopefully this is already handled by Preferences class
//                return
//            }
//            
//            guard let lines = logFileHandle.readLines() else {
//                return
//            }
//            
//            
//            for line in lines {
//                if let software = Software(sourceRegEx: initRegex, from: line) {
//                    
//                    DispatchQueue.main.async {
//                        SoftwareArray.sharedInstance.array.modify(with: software)
//                        
//                    }
//                    
//                }
//            }
//            
//        }
//        
//    }
//    
//    func readTimerForFW() -> Void {
//        DispatchQueue.global(qos: .background).async {
//            
//            guard let logFileHandle = Preferences.sharedInstance.logFileHandleForFW else {
//                // Hopefully this is already handled by Preferences class
//                return
//            }
//            
//            guard let lines = logFileHandle.readLines() else {
//                return
//            }
//            
//            
//            for line in lines {
//                if let software = Software(sourceRegEx: initRegexForFW, from: line) {
//                    
//                    DispatchQueue.main.async {
//                        SoftwareArray.sharedInstance.array.modify(with: software)
//                        
//                    }
//                    
//                }
//            }
//            
//        }
//    }
}
