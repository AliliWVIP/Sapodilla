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
}
