//
//  SapodillaManager+NSURLSessionDelegate.swift
//  Sapodilla
//
//  Created by li wang on 2019/12/26.
//  Copyright © 2019 li wang. All rights reserved.
//

import Foundation

private typealias URLSessionDelegate = SapodillaManager

extension URLSessionDelegate {
    /**
    a delegate method to check whether the remote cartification is the same with given certification.
    
    - parameter session:           NSURLSession
    - parameter challenge:         NSURLAuthenticationChallenge
    - parameter completionHandler: the completionHandler closure
    */
    @objc(URLSession:didReceiveChallenge:completionHandler:) func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if self.localCertDataArray.count == 0 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, nil)
            return
        }
        
        
        
        if let serverTrust = challenge.protectionSpace.serverTrust,
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let remoteCertificateData: Data = SecCertificateCopyData(certificate) as Data
            
            var checked = false
            
            for localCertificateData in self.localCertDataArray {
                if localCertificateData as Data == remoteCertificateData {
                    if !checked {
                        checked = true
                    }
                }
            }

            if checked {
                let credential = URLCredential(trust: serverTrust)
                challenge.sender?.use(credential, for: challenge)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, credential)
            } else {
                challenge.sender?.cancel(challenge)
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                DispatchQueue.main.async {
                    self.sSLValidateErrorCallBack?()
                }
                return
            }
        } else {
            // could not test
            print("Sapolilla: Get RemoteCertificateData or LocalCertificateData error!")
        }
    }
}
