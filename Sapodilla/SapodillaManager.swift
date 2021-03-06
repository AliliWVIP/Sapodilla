//
//  SapodillaManager.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/26.
//  Copyright © 2019 li wang. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}
class SapodillaManager: NSObject, URLSessionDataDelegate {
    let boundary = "Sapodilla"
    let errorDomain = "top.aliliwvip.Sapodilla"
    
    var HTTPBodyRaw = ""
    var HTTPBodyRawIsJSON = false
    
    let method: String!
    var params: [String: Any]?
    var files: [SapodillaFile]?
    var cancelCallback: (() -> Void)?
    var errorCallback: ((_ error: NSError) -> Void)?
    var callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)?
    
    var session: URLSession!
    let url: String!
    var request: URLRequest!
    var task: URLSessionTask!
    var basicAuth: (String, String)!
    
    var localCertDataArray = [Data]()
    var sSLValidateErrorCallBack: (() -> Void)?
    
    var extraHTTPHeaders = [(String, String)]()
    
    var execution: SapodillaExecution = .async
    
    // User-Agent Header; see http://tools.ietf.org/html/rfc7231#section-5.5.3
    let userAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable: Any = info[kCFBundleExecutableKey as String] ?? "Unknown"
            let bundle: Any = info[kCFBundleIdentifierKey as String] ?? "Unknown"
            let version: Any = info[kCFBundleVersionKey as String] ?? "Unknown"
            // could not tested
            let os = ProcessInfo.processInfo.operatingSystemVersionString
            
            var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
            let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
            if CFStringTransform(mutableUserAgent, nil, transform, false) {
                return mutableUserAgent as NSString as String
            }
        }
        
        // could not tested
        return "Sapodilla"
        }()

    init(url: String, method: HTTPMethod!, timeout: Double = 60.0, execution: SapodillaExecution = .async) {
        self.url = url
        self.request = URLRequest(url: URL(string: url)!)
        self.method = method.rawValue
        self.execution = execution
        
        super.init()
        // setup a session with delegate to self
        let sessionConfiguration = Foundation.URLSession.shared.configuration
        sessionConfiguration.timeoutIntervalForRequest = timeout
        self.session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: Foundation.URLSession.shared.delegateQueue)
    }
    func addSSLPinning(LocalCertData dataArray: [Data], SSLValidateErrorCallBack: (()->Void)? = nil) {
        self.localCertDataArray = dataArray
        self.sSLValidateErrorCallBack = SSLValidateErrorCallBack
    }
    func addParams(_ params: [String: Any]?) {
        self.params = params
    }
    func addFiles(_ files: [SapodillaFile]?) {
        self.files = files
    }
    func addErrorCallback(_ errorCallback: ((_ error: NSError) -> Void)?) {
        self.errorCallback = errorCallback
    }
    func setHTTPHeader(Name key: String, Value value: String) {
        self.extraHTTPHeaders.append((key, value))
    }
    func sethttpBodyRaw(_ rawString: String, isJSON: Bool = false) {
        self.HTTPBodyRaw = rawString
        self.HTTPBodyRawIsJSON = isJSON
    }
    func setBasicAuth(_ auth: (String, String)) {
        self.basicAuth = auth
    }
    func fire(_ callback: ((_ data: Data?, _ response: HTTPURLResponse?) -> Void)? = nil) {
        self.callback = callback
        
        self.buildRequest()
        self.buildHeader()
        self.buildBody()
        self.fireTask()
    }
    fileprivate func buildRequest() {
        if self.method == "GET" && self.params?.count > 0 {
            self.request = URLRequest(url: URL(string: url + "?" + SapodillaHelper.buildParams(self.params!))!)
        }
        self.request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        self.request.httpMethod = self.method
    }
    fileprivate func buildHeader() {
        // multipart Content-Type; see http://www.rfc-editor.org/rfc/rfc2046.txt
        if self.params?.count > 0 {
            self.request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        if self.files?.count > 0 && self.method != "GET" {
            self.request.setValue("multipart/form-data; boundary=" + self.boundary, forHTTPHeaderField: "Content-Type")
        }
        if self.HTTPBodyRaw != "" {
            self.request.setValue(self.HTTPBodyRawIsJSON ? "application/json" : "text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        }
        self.request.addValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        if let auth = self.basicAuth {
            let authString = "Basic " + (auth.0 + ":" + auth.1).base64
            self.request.addValue(authString, forHTTPHeaderField: "Authorization")
        }
        for i in self.extraHTTPHeaders {
            self.request.setValue(i.1, forHTTPHeaderField: i.0)
        }
    }
    fileprivate func buildBody() {
        let data = NSMutableData()
        if self.HTTPBodyRaw != "" {
            data.append(self.HTTPBodyRaw.nsdata as Data)
        } else if self.files?.count > 0 {
            if self.method == "GET" {
                print("\n\n------------------------\nThe remote server may not accept GET method with HTTP body. But Pitaya will send it anyway.\nBut it looks like iOS 9 SDK has prevented sending http body in GET method.\n------------------------\n\n")
            } else {
                if let ps = self.params {
                    for (key, value) in ps {
                        data.append("--\(self.boundary)\r\n".nsdata as Data)
                        data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".nsdata as Data)
                        data.append("\(value)\r\n".nsdata as Data)
                    }
                }
                if let fs = self.files {
                    for file in fs {
                        data.append("--\(self.boundary)\r\n".nsdata as Data)
                        data.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.nameWithType)\"\r\n\r\n".nsdata as Data)
                        if let fileurl = file.url {
                            if let a = try? Data(contentsOf: fileurl as URL) {
                                data.append(a)
                                data.append("\r\n".nsdata as Data)
                            }
                        } else if let filedata = file.data {
                            data.append(filedata)
                            data.append("\r\n".nsdata as Data)
                        }
                    }
                }
                data.append("--\(self.boundary)--\r\n".nsdata as Data)
            }
        } else if self.params?.count > 0 && self.method != "GET" {
            data.append(SapodillaHelper.buildParams(self.params!).nsdata)
        }
        self.request.httpBody = data as Data
    }
    fileprivate func fireTask() {
        if Sapodilla.DEBUG { if let a = self.request.allHTTPHeaderFields { print("Sapodilla Request HEADERS: ", a.description); }; }
        let semaphore = DispatchSemaphore(value: 0)
        self.task = self.session.dataTask(with: self.request) { [weak self] (data, response, error) -> Void in
            if Sapodilla.DEBUG { if let a = response { print("Sapodilla Response: ", a.description); }}
            semaphore.signal()
            if let error = error as NSError? {
                if error.code == -999 {
                    DispatchQueue.main.async {
                        self?.cancelCallback?()
                    }
                } else {
                    let e = NSError(domain: self?.errorDomain ?? "Sapodilla", code: error.code, userInfo: error.userInfo)
                    print("Sapodilla Error: ", e.localizedDescription)
                    DispatchQueue.main.async {
                        self?.errorCallback?(e)
                        self?.session.finishTasksAndInvalidate()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.callback?(data, response as? HTTPURLResponse)
                    self?.session.finishTasksAndInvalidate()
                }
            }
        }
        self.task.resume()
        if execution == .sync{
            semaphore.wait()
        }
    }
}
