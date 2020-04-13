//
//  Sapodilla.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/26.
//  Copyright © 2019 li wang. All rights reserved.
//

import UIKit
class Sapodilla {
    /// if set to true, Pitaya will log all information in a NSURLSession lifecycle
    public static var DEBUG = false
    
    var sapodillaManager: SapodillaManager!

    /**
    the only init method to fire a HTTP / HTTPS request
    
    - parameter method:     the HTTP method you want
    - parameter url:        the url you want
    - parameter timeout:    time out setting
    
    - returns: a Pitaya object
    */
    public static func build(HTTPMethod method: HTTPMethod, url: String) -> Sapodilla {
        let p = Sapodilla()
        p.sapodillaManager = SapodillaManager.build(method, url: url)
        return p
    }
    public static func build(HTTPMethod method: HTTPMethod, url: String, timeout: Double, execution: SapodillaExecution = .async) -> Sapodilla {
        let p = Sapodilla()
        p.sapodillaManager = SapodillaManager.build(method, url: url, timeout: timeout, execution: execution)
        return p
    }
    
    /**
    add params to self (Pitaya object)
    
    - parameter params: what params you want to add in the request. Pitaya will do things right whether methed is GET or POST.
    
    - returns: self (Pitaya object)
    */
    open func addParams(_ params: [String: Any]) -> Sapodilla {
        self.sapodillaManager.addParams(params)
        return self
    }
    
    /**
    add files to self (Pitaya object), POST only
    
    - parameter params: add some files to request
    
    - returns: self (Pitaya object)
    */
    open func addFiles(_ files: [SapodillaFile]) -> Sapodilla {
        self.sapodillaManager.addFiles(files)
        return self
    }
    
    /**
    add a SSL pinning to check whether undering the Man-in-the-middle attack
    
    - parameter data:                     data of certification file, .cer format
    - parameter SSLValidateErrorCallBack: error callback closure
    
    - returns: self (Pitaya object)
    */
    open func addSSLPinning(LocalCertData data: Data, SSLValidateErrorCallBack: (()->Void)? = nil) -> Sapodilla {
        self.sapodillaManager.addSSLPinning(LocalCertData: [data], SSLValidateErrorCallBack: SSLValidateErrorCallBack)
        return self
    }
    
    /**
     add a SSL pinning to check whether undering the Man-in-the-middle attack
     
     - parameter LocalCertDataArray:       data array of certification file, .cer format
     - parameter SSLValidateErrorCallBack: error callback closure
     
     - returns: self (Pitaya object)
     */
    open func addSSLPinning(LocalCertDataArray dataArray: [Data], SSLValidateErrorCallBack: (()->Void)? = nil) -> Sapodilla {
        self.sapodillaManager.addSSLPinning(LocalCertData: dataArray, SSLValidateErrorCallBack: SSLValidateErrorCallBack)
        return self
    }
    
    /**
    set a custom HTTP header
    
    - parameter key:   HTTP header key
    - parameter value: HTTP header value
    
    - returns: self (Pitaya object)
    */
    open func setHTTPHeader(Name key: String, Value value: String) -> Sapodilla {
        self.sapodillaManager.setHTTPHeader(Name: key, Value: value)
        return self
    }

    /**
    set HTTP body to what you want. This method will discard any other HTTP body you have built.
    
    - parameter string: HTTP body string you want
    - parameter isJSON: is JSON or not: will set "Content-Type" of HTTP request to "application/json" or "text/plain;charset=UTF-8"
    
    - returns: self (Pitaya object)
    */
    open func setHTTPBodyRaw(_ string: String, isJSON: Bool = false) -> Sapodilla {
        self.sapodillaManager.sethttpBodyRaw(string, isJSON: isJSON)
        return self
    }
    
    /**
    set username and password of HTTP Basic Auth to the HTTP request header
    
    - parameter username: username
    - parameter password: password
    
    - returns: self (Pitaya object)
    */
    open func setBasicAuth(_ username: String, password: String) -> Sapodilla {
        self.sapodillaManager.setBasicAuth((username, password))
        return self
    }
    
    /**
    add error callback to self (Pitaya object).
    this will called only when network error, if we can receive any data from server, responseData() will be fired.
    
    - parameter errorCallback: errorCallback Closure
    
    - returns: self (Pitaya object)
    */
    open func onNetworkError(_ errorCallback: @escaping ((_ error: NSError) -> Void)) -> Sapodilla {
        self.sapodillaManager.addErrorCallback(errorCallback)
        return self
    }
    
    /**
    async response the http body in NSData type
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func responseData(_ callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)?) {
        self.sapodillaManager?.fire(callback)
    }
    
    /**
    async response the http body in String type
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func responseString(_ callback: ((_ string: String?, _ response: HTTPURLResponse?) -> Void)?) {
        self.responseData { (data, response) -> Void in
            var string = ""
            if let d = data,
                let s = NSString(data: d, encoding: String.Encoding.utf8.rawValue) as String? {
                    string = s
            }
            callback?(string, response)
        }
    }
    
    /**
    async response the http body in JSON type use JSONNeverDie(https://github.com/johnlui/JSONNeverDie).
    
    - parameter callback: callback Closure
    - parameter response: void
    */
    open func responseJSON(_ callback: ((_ json: Dictionary<String, Any>?, _ response: HTTPURLResponse?) -> Void)?) {
        self.responseString { (string, response) in
            var json = Dictionary<String, Any>()
            if let s = string {
                json = Dictionary.constructFromJSON(json: s)!
            }
            callback?(json, response)
        }
    }
    
    /**
    cancel the request.
     
     - parameter callback: callback Closure
     */
    open func cancel(_ callback: (() -> Void)?) {
        self.sapodillaManager.cancelCallback = callback
        self.sapodillaManager.task.cancel()
    }
}
