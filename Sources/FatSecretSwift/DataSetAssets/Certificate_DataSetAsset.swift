//
//  FBDataSetAssets.swift
//  iFoodSearch
//
//  Created by Super Grover on 2023-10-01.
//  Copyright © 2023 Super Grover. All rights reserved.
//

import UIKit


// Retreive API and Secret "D" keys, for "C XOR D = E (final, flipped) key", from Data Asset files in Project Assets.
// NB: Will grab 32 or the 40 bytes (have 8 tail random obfuscating bytes).
struct Certificate_DataSetAsset {
//    // Binary array keys stored in Keychain; imageD1_in_KC = apiKeyD_bytes, imageD2_in_KC = secretKeyD_bytes
//    static var imageD1_in_KC: [UInt8]? {
//        get {
//            guard let data = KeychainWrapper.standard.data(forKey: kImageKey.D1.id) else { return nil }
//            var buffer = [UInt8](repeating: 0, count: 32)
//            data.copyBytes(to: &buffer, count: 32)
//            return buffer
//        }
//        set(newValue) {
//            guard let newValue = newValue else { return }
//            let data = Data(newValue)
//            KeychainWrapper.standard.set(data, forKey: kImageKey.D1.id)
//        }
//    }
//
//    static var imageD2_in_KC: [UInt8]? {
//        get {
//            guard let data = KeychainWrapper.standard.data(forKey: kImageKey.D2.id) else { return nil }
//            var buffer = [UInt8](repeating: 0, count: 32)
//            data.copyBytes(to: &buffer, count: 32)
//            return buffer
//        }
//        set(newValue) {
//            guard let newValue = newValue else { return }
//            let data = Data(newValue)
//            KeychainWrapper.standard.set(data, forKey: kImageKey.D2.id)
//        }
//    }
    
    
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
    func certificate(from kc_uint8Array: inout Data?, orFile filename: String) throws -> Data {
        // NB: below breakpoint resets uint8Array to nil!!!
        switch kc_uint8Array {
        case .some:
            print("retrieving binary key from keychain") // Can't use breakpoint here as will hang (because of DispatchGroup?)
            return kc_uint8Array!  // return byte array stored in keychain as Int32 array
            
        case .none:
            do {
                let dataAsset   = try dataAssetWithName(filename)   // Try to load local NSDataSet
                let key_Int32Array  = certificate_fromDataAsset(dataAsset)
                kc_uint8Array          = key_Int32Array    // Will save key into keychain; NB: is passed in by reference.
                print("retrieving binary key from file") // Can't use breakpoint here as will hang (because of DispatchGroup?)
                return key_Int32Array
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
                let key_Int32Array  = certificate_fromDataAsset(dataAsset)
                completed(.success(key_Int32Array))
                
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
                let key_Int32Array  = certificate_fromDataAsset(dataAsset)
                kc_certificateData  = key_Int32Array    // Will save key into keychain; NB: is passed in by reference.
                print("retrieving kc_certificateData") // Can't use breakpoint here as will hang (because of DispatchGroup?)
                return key_Int32Array
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
