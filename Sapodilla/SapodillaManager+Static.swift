//
//  SapodillaManager+Static.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/26.
//  Copyright © 2019 li wang. All rights reserved.
//

import UIKit

extension SapodillaManager {
    /**
       the only init method of PitayaManager
       
       - parameter method: HTTP request method
       - parameter url:    HTTP request url
       
       - returns: self (PitayaManager object)
       */
       static func build(_ method: HTTPMethod, url: String, timeout: Double = 60.0, execution: SapodillaExecution = .async) -> SapodillaManager {
           return SapodillaManager(url: url, method: method, timeout: timeout, execution: execution)
       }
}
