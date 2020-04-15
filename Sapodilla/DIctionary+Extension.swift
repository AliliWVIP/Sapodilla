//
//  DIctionary+Extension.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/26.
//  Copyright © 2019 li wang. All rights reserved.
//

import Foundation

extension Dictionary {
    public static func constructFromJSON (json: String) -> Dictionary? {
        if let data = (try? JSONSerialization.jsonObject(
            with: json.data(using: String.Encoding.utf8,
                            allowLossyConversion: true)!,
            options: JSONSerialization.ReadingOptions.mutableContainers)) as? Dictionary {
            return data
        } else {
            return nil
        }
    }
    
    public static func getJSONStringFromDictionary(dictionary:Dictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            print("invalid jsonString")
            return ""
        }
        let data : Data! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as Data?
        let jsonString: String = String(bytes: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        return jsonString

//        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
    }

    //数组转json
    func getJSONStringFromArray(array:Array<Any>) -> String {
         
        if (!JSONSerialization.isValidJSONObject(array)) {
            print("invalid jsonString")
            return ""
        }
         
        let data : Data! = try? JSONSerialization.data(withJSONObject: array, options: []) as Data?
        let jsonString: String = String(bytes: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        return jsonString

//        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
//        return JSONString! as String
//
    }
}
