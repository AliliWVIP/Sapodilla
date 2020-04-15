//
//  SapHelper.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/13.
//  Copyright © 2019 li wang. All rights reserved.
//

import UIKit

class SapodillaHelper: NSObject {
    
    static func buildParams(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value = parameters[key]
            components += SapodillaHelper.queryComponents(key, value ?? "value_is_nil")
        }
        
        return components.map{"\($0)=\($1)"}.joined(separator: "&")
    }

    static func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        var valueString = ""
        
        switch value {
        case _ as String:
            valueString = value as! String
        case _ as Bool:
            valueString = (value as! Bool).description
        case _ as Double:
            valueString = (value as! Double).description
        case _ as Int:
            valueString = (value as! Int).description
        default:
            break
        }
        
        components.append(contentsOf: [(SapodillaHelper.escape(key), SapodillaHelper.escape(valueString))])
        return components
    }

    static func escape(_ string: String) -> String {
        let legalURLCharactersToBeEscaped: String = ":&=;+!@#$()',*"
        let charSet: CharacterSet = CharacterSet.init(charactersIn: legalURLCharactersToBeEscaped)
        return string.addingPercentEncoding(withAllowedCharacters: charSet) ?? ""
    }
}
