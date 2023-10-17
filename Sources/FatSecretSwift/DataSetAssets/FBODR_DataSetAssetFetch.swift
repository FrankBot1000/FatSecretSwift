//
//  FBODR_AssetFetch.swift
//  iFoodSearch
//
//  Created by Super Grover on 2023-10-01.
//  Copyright © 2023 Super Grover. All rights reserved.
//

import Foundation
import UIKit

enum FBAssetError: String, Error {
    case unableToDownLoad   = "Unable to download ODR Asset."
    case unableToLoadFile   = "Unable to load local file asset."
    case unknownError       = "Missing Data. WTF...unknown error."
}


enum FBAssetTag: String {
    case ODR_tag_FatSecret_CurrentCert = "ODR_tag_FatSecret_CurrentCert"
    
    var name: String {
        return self.rawValue
    }
}


struct FBODR_DataSetAssetFetch {
    
    func fetchAssetWith(tag assetTag: String, orFile filename: String, completed: @escaping (Result<NSDataAsset, FBAssetError>) -> Void) {
        let currentRequest:  NSBundleResourceRequest? = NSBundleResourceRequest(tags: [assetTag])
        guard let request = currentRequest else { return }
        
        request.conditionallyBeginAccessingResources { resourceAvailable in
//            var isResourceAvailable = resourceAvailable // isResourceAvailable is mutated in breakpoint
            switch resourceAvailable {
            case false:
                request.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent
                request.beginAccessingResources(completionHandler: { error in
                    switch error {
                    case .some:
                        completed(.failure(FBAssetError.unableToDownLoad))
                        request.endAccessingResources()
                        return
                    case .none:
                        request.endAccessingResources()
                        do {
                            let dataAsset = try dataAssetWithName(filename)
                            completed(.success(dataAsset))
                        } catch let error {
                            guard let dataError = error as? FBAssetError else {
                                completed(.failure(FBAssetError.unknownError))
                                return
                            }
                            completed(.failure(dataError))
                            return
                        }
                    }
                })
                
            // Is true when resource is already available on device:
            case true:
                do {
                    let dataAsset = try dataAssetWithName(filename)
                    completed(.success(dataAsset))
                } catch {
                    completed(.failure(.unableToDownLoad))
                }
            }
        }
    }
    
    
    private func dataAssetWithName(_ name: String) throws -> NSDataAsset {
        guard let asset = NSDataAsset(name: name) else {
            print("Missing data asset: \(name)")
            throw FBAssetError.unableToLoadFile
        }
        return asset
    }
    
}
