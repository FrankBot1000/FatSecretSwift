//
//  Certificate.swift
//  
//
//  Created by Super Grover on 2023-10-15.
//
// Adapted from: https://gist.github.com/daniel-rueda/132c1a556dad7cf6b734b59ed47a1f75
// Based on https://code.tutsplus.com/articles/securing-communications-on-ios--cms-28529

import Foundation
import Security

// For expired + upcoming certificate
enum kCertificate: String {
    case renewed    = "fatsecretCurrent_new"    // Certificate Renewed
    case current    = "fatsecretCurrent"        // Certificate
    case domain     = "platform.fatsecret.com"  // Domain to Validate
    
    var name: String {
        self.rawValue
    }
}


struct Certificate {
    let certificate: SecCertificate
    let data: Data
}

extension Certificate {

    @available(*, deprecated, message: "Use localCertificates(from datas: [Data])->[Certificate] {...} instead.")
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
    
    
    static func localCertificates(from datas: [Data]) -> [Certificate] {
        return datas.lazy.map({
            guard let secCert = SecCertificateCreateWithData(nil, $0 as CFData) else { return nil }
            return Certificate(certificate: secCert, data: $0)
        }).compactMap({$0})
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
    
    public var certificateDatas: [Data]
    
    public init(certificateDatas: [Data]) {
        self.certificateDatas = certificateDatas
    }
    
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
        let certificates = Certificate.localCertificates(from: certificateDatas)
        for localCert in certificates {
            let isLocalCertificateValid = localCert.validate(against: serverCertificateData, using: serverTrust)
            if isLocalCertificateValid {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return // exit as soon as we found a match
            }
        }

        // No valid cert available
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
