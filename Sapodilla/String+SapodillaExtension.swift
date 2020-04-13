//
//  String+SapExtension.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/13.
//  Copyright © 2019 li wang. All rights reserved.
//

import Foundation

extension String {
    /// return NSData of self String
    var nsdata: Data {
        return self.data(using: String.Encoding.utf8)!
    }
    
    /// return base64 string of self String
    var base64: String! {
        let utf8EncodeData: Data! = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        let base64EncodingData = utf8EncodeData.base64EncodedString(options: [])
        return base64EncodingData
    }
}
