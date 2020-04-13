//
//  SapFile.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/13.
//  Copyright © 2019 li wang. All rights reserved.
//

/**
*  the file struct for Sapodilla to upload
*/

import Foundation

public struct SapodillaFile {
    public let name: String
    public let nameWithType: String
    public let url: URL?
    public let data: Data?
    
    public init(name: String, url: URL) {
        self.name = name
        self.url = url
        self.data = nil
        self.nameWithType = NSString(string: url.description).lastPathComponent
    }
    
    public init(name:String, data: Data, type: String) {
        self.name = name
        self.data = data
        self.url  = nil
        self.nameWithType = name + "." + type
    }
}

