//
//  CloudDataManager.swift
//  CloudKitStarter
//
//  Created by Steven Shang on 3/8/18.
//  Copyright © 2018 cocoanuts. All rights reserved.
//

import UIKit
import CloudKit

protocol CloudDataManagerDelegate {
    
    func reportError(error: Error)
    func dataUpdated()
}

class CloudDataManager {
    
    static let shared = CloudDataManager()

    var delegate: CloudDataManagerDelegate?
    
    var data: [CKRecord] = []
    let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
    let userPostType = "Post"

    func currentDate() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        let dateString = formatter.string(from: date)
        return dateString
        
    }
    
    func retrieveData() {
        
        let predicate = NSPredicate(format: "Date = %@", currentDate())
        
        let query = CKQuery(recordType: userPostType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        publicDB.perform(query, inZoneWith: nil) { (results, error) in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.reportError(error: error)
                }
                return
            }
            
            self.data.removeAll(keepingCapacity: true)
            
            results?.forEach({ (record) in
                self.data.append(record)
            })
            
            DispatchQueue.main.async {
                self.delegate?.dataUpdated()
            }
        }
    }

    func saveData(image: UIImage, date: String) {
        
        let record:CKRecord = CKRecord(recordType: userPostType)
        
        let filename = ProcessInfo.processInfo.globallyUniqueString + ".PNG"
        let url = NSURL.fileURL(withPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        let data = UIImagePNGRepresentation(image)!
        do {
            try data.write(to: url, options: Data.WritingOptions.atomicWrite)
        } catch {
            return
        }
        
        let asset = CKAsset(fileURL: url)
        
        record.setValue(asset, forKey: "Image")
        record.setValue(date, forKey: "Date")
        
        publicDB.save(record) { savedRecord, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.reportError(error: error)
                }
            }
        }
    }
    
    func loadData(index: Int, completion: @escaping (UIImage?, String?)->()) {
        
        DispatchQueue.global(qos: .background).async {
            
            var image: UIImage!
            var date: String!
            var record = self.data[index]
            
            defer {
                DispatchQueue.main.async {
                    completion(image, date)
                }
            }
            
            guard let dateData = record["Date"] as? String else {
                return
            }
            
            guard let asset = record["Image"] as? CKAsset else {
                return
            }
            
            let imageData: Data
            
            do {
                imageData = try Data(contentsOf: asset.fileURL)
            } catch {
                return
            }
            
            image = UIImage(data: imageData)
            date = dateData
        }
        
    }
}
