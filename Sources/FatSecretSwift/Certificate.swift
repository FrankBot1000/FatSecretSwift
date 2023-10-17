//
//  Certificate.swift
//  
//
//  Created by Super Grover on 2023-10-15.
//
// Adapted from: https://gist.github.com/daniel-rueda/132c1a556dad7cf6b734b59ed47a1f75
// Based on https://code.tutsplus.com/articles/securing-communications-on-ios--cms-28529

import UIKit
import Security

// For expired + upcoming certificate
enum kCertificate: String {
    case renewed    = "CertificateRenewed"      // CertificateRenewed; use placeholder for now
    case current    = "fatsecretCurrent"        // Certificate
    case domain     = "platform.fatsecret.com"  // domain to validate
    
    var name: String {
        self.rawValue
    }
}


struct Certificate {
    let certificate: SecCertificate
    let data: Data
}

extension Certificate {
    static func localCertificates(with names: [String] = [kCertificate.renewed.name, kCertificate.current.name],
                                  from bundle: Bundle = .main) -> [Certificate] {
        return names.lazy.map({
            guard let file = bundle.url(forResource: $0, withExtension: "der"),
                let data = try? Data(contentsOf: file),
                let cert = SecCertificateCreateWithData(nil, data as CFData) else {
                    return nil
            }
            return Certificate(certificate: cert, data: data)
        }).compactMap({$0})
    }
    
    
    static func localCertificate(from assetTag : String, orFile filename: String, orKeyChain kc_certificateData: inout Data?) -> Certificate? {
        let dataSetAsset = Certificate_DataSetAsset()
        var key_Data: Data?
        var kc_keyCopy = kc_certificateData
        
        let myGroup = DispatchGroup()
        
        do {
            key_Data = try dataSetAsset.certificateData(from: &kc_certificateData, orFile: filename)
        } catch {
            myGroup.enter()
            dataSetAsset.certificate(fromAssetTag: assetTag, orFile: filename, completed: { result in
                switch result {
                case .success(let int32Array):
                    key_Data  = int32Array
                    kc_keyCopy = key_Data
                case .failure(let error):
                    print(error)
                }
                myGroup.leave()
            })
            key_Data = kc_keyCopy
            myGroup.wait()
        }
        
        guard let certificate = SecCertificateCreateWithData(nil, key_Data! as CFData) else { return nil }
        return Certificate(certificate: certificate, data: key_Data!)
        
//        let dataSetAsset = FBDataSetAsset()
//        var dataAsset: NSDataAsset?
//
//        dataSetAsset.dataAsset(withTag: assetTag, orFile: "fatsecretCurrent", completed: { result in
//            switch result {
//            case .success(let dataAsset):
//                let data = dataAsset.data as Data
//                let certificate = SecCertificateCreateWithData(nil, data as CFData)
//                return Certificate(certificate: certificate, data: data)
//
//            case .failure(let error):
//                print(error)
//            }
//        })
    }
    

    func validate(against certData: Data, using secTrust: SecTrust) -> Bool {
        let certArray = [certificate] as CFArray
        SecTrustSetAnchorCertificates(secTrust, certArray)

        //validates a certificate by verifying its signature plus the signatures of
        // the certificates in its certificate chain, up to the anchor certificate
        var result = SecTrustResultType.invalid
        SecTrustEvaluate(secTrust, &result)
        let isValid = (result == .unspecified || result == .proceed)

        //Validate host certificate against pinned certificate.
        return isValid && certData == self.data
    }
}

public class CertificatePinningURLSessionDelegate: NSObject, URLSessionDelegate {
    public func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }

        //Set policy to validate domain
        let policy = SecPolicyCreateSSL(true, kCertificate.domain.name as CFString)
        let policies = NSArray(object: policy)
        SecTrustSetPolicies(serverTrust, policies)

        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0,
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }

        let serverCertificateData = SecCertificateCopyData(certificate) as Data
        let certificates = Certificate.localCertificates()
        for localCert in certificates {
            if localCert.validate(against: serverCertificateData, using: serverTrust) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return // exit as soon as we found a match
            }
        }

        // No valid cert available
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}


// --------------------------------------------------------------------------------------------------------
// Above, nicely cleans up the below
// from: https://code.tutsplus.com/articles/securing-communications-on-ios--cms-28529:
class URLSessionPinningDelegate: NSObject, URLSessionDelegate
{
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void)
    {
        var success: Bool = false
        if let serverTrust = challenge.protectionSpace.serverTrust
        {
            if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
            {
                //Set policy to validate domain
                let policy: SecPolicy = SecPolicyCreateSSL(true, "yourdomain.com" as CFString)
                let policies = NSArray.init(object: policy)
                SecTrustSetPolicies(serverTrust, policies)
                
                let certificateCount: CFIndex = SecTrustGetCertificateCount(serverTrust)
                if certificateCount > 0
                {
                    if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                    {
                        let serverCertificateData = SecCertificateCopyData(certificate) as NSData
                        
                        //for loop over array which may contain expired + upcoming certificate
                        let certFilenames: [String] = ["CertificateRenewed", "Certificate"]
                        for filenameString: String in certFilenames
                        {
                            let filePath = Bundle.main.path(forResource: filenameString, ofType: "cer")
                            if let file = filePath
                            {
                                if let localCertData = NSData(contentsOfFile: file)
                                {
                                    //Set anchor cert to your own server
                                    if let localCert: SecCertificate = SecCertificateCreateWithData(nil, localCertData)
                                    {
                                        let certArray = [localCert] as CFArray
                                        SecTrustSetAnchorCertificates(serverTrust, certArray)
                                    }
                                    
                                    //validates a certificate by verifying its signature plus the signatures of the certificates in its certificate chain, up to the anchor certificate
                                    var result = SecTrustResultType.invalid
                                    SecTrustEvaluate(serverTrust, &result);
                                    let isValid: Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)
                                    if (isValid)
                                    {
                                        //Validate host certificate against pinned certificate.
                                        if serverCertificateData.isEqual(to: localCertData as Data)
                                        {
                                            success = true
                                            completionHandler(.useCredential, URLCredential(trust:serverTrust))
                                            break //found a successful certificate, don't need to continue looping
                                        } //end if serverCertificateData.isEqual(to: localCertData as Data)
                                    } //end if (isValid)
                                } //end if let localCertData = NSData(contentsOfFile: file)
                            } //end if let file = filePath
                        } //end for filenameString: String in certFilenames
                    } //end if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)
                } //end if certificateCount > 0
            } //end if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        } //end if let serverTrust = challenge.protectionSpace.serverTrust
        
        if (success == false)
        {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
