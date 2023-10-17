//
//  FBDataSetAssets.swift
//  iFoodSearch
//
//  Created by Super Grover on 2023-10-01.
//  Copyright © 2023 Super Grover. All rights reserved.
//

import UIKit


enum kCertKey: String, RawRepresentable {
    case CA_Key     = "CA_Key"
    case publicKey  = "publicKey"
    
    var id: String {
        return self.rawValue
    }
}




// Retreive API and Secret "D" keys, for "C XOR D = E (final, flipped) key", from Data Asset files in Project Assets.
// NB: Will grab 32 or the 40 bytes (have 8 tail random obfuscating bytes).
struct Certificate_DataSetAsset {

    static var fatSecretCert_KC: Data? {
        get {
            guard let data = KeychainWrapper.standard.data(forKey: kCertKey.CA_Key.id) else { return nil }
            return data
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            let data = Data(newValue)
            KeychainWrapper.standard.set(data, forKey: kCertKey.CA_Key.id)
        }
    }
    
    
    static var fatSecretPublicKey_KC: Data? {
        get {
            guard let data = KeychainWrapper.standard.data(forKey: kCertKey.publicKey.id) else { return nil }
            return data
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            let data = Data(newValue)
            KeychainWrapper.standard.set(data, forKey: kCertKey.publicKey.id)
        }
    }
    
    
    
    func dataAssetWithName(_ name: String) throws -> NSDataAsset {
        guard let asset = NSDataAsset(name: name) else {
            print("Missing data asset: \(name)")
            throw Certificate_AssetError.unableToLoadFile
        }
        return asset
    }
    
    
    
    func certificate_fromDataAsset(_ asset: NSDataAsset) -> Data {
        return asset.data
    }
    
    
    /// Attempts to retreive data from keychain or file.
    func certificate(from kc_keyData: inout Data?, orFile filename: String) throws -> Data {
        // NB: below breakpoint resets uint8Array to nil!!!
        switch kc_keyData {
        case .some:
            print("retrieving binary key from keychain") // Can't use breakpoint here as will hang (because of DispatchGroup?)
            return kc_keyData!  // return byte array stored in keychain as Int32 array
            
        case .none:
            do {
                let dataAsset   = try dataAssetWithName(filename)   // Try to load local NSDataSet
                let key_data  = certificate_fromDataAsset(dataAsset)
                kc_keyData          = key_data    // Will save key into keychain; NB: is passed in by reference.
                print("retrieving binary key from file") // Can't use breakpoint here as will hang (because of DispatchGroup?)
                return key_data
            } catch {
                print("Catch-all for other errors... Unable to load/retreive Data Asset")
                throw Certificate_AssetError.unableToDownLoad
            }
        }
    }
    
    
    /// Attempts to retreive data from On-Demand Resource data asset file.
    func certificate(fromAssetTag assetTag: String, orFile filename: String, completed: @escaping (Result<Data, Certificate_AssetError>) -> Void) {
        let odr_assetFetch  = Certificate_DataSetAssetFetch() // Attempt to fetch from on-line on-demand resource
        odr_assetFetch.fetchAssetWith(tag: assetTag, orFile: filename) { result in
            switch result {
            case .success(let dataAsset):
                let key_data  = certificate_fromDataAsset(dataAsset)
                completed(.success(key_data))
                
            case .failure(let error):
                print("Missing data.... Error: \(error)")
                completed(.failure(Certificate_AssetError.unableToDownLoad))
            }
        }
    }
    
    
    /// Attempts to retreive data from keychain or file.
    func certificateData(from kc_certificateData: inout Data?, orFile filename: String) throws -> Data? {
        // NB: below breakpoint resets uint8Array to nil!!!
        switch kc_certificateData {
        case .some:
            print("retrieving kc_certificateData")
            return kc_certificateData
            
        case .none:
            do {
                let dataAsset       = try dataAssetWithName(filename)   // Try to load local NSDataSet
                let key_data  = certificate_fromDataAsset(dataAsset)
                kc_certificateData  = key_data    // Will save key into keychain; NB: is passed in by reference.
                print("retrieving kc_certificateData") // Can't use breakpoint here as will hang (because of DispatchGroup?)
                return key_data
            } catch {
                print("Catch-all for other errors... Unable to load/retreive Data Asset")
                throw Certificate_AssetError.unableToDownLoad
            }
        }
    }
    
    
    
    /// Attempts to data asset from On-Demand Resource data asset file.
    func dataAsset(withTag assetTag: String, orFile filename: String, completed: @escaping (Result<NSDataAsset, Certificate_AssetError>) -> Void) {
        let odr_assetFetch  = Certificate_DataSetAssetFetch() // Attempt to fetch from on-line on-demand resource
        odr_assetFetch.fetchAssetWith(tag: assetTag, orFile: filename) { result in
            switch result {
            case .success(let dataAsset):
                completed(.success(dataAsset))
            
            case .failure(let error):
                print("Missing data.... Error: \(error)")
                completed(.failure(Certificate_AssetError.unableToDownLoad))
            }
        }
    }
    
}
