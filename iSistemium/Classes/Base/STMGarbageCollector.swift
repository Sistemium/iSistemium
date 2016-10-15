//
//  STMGarbageCollector.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 19/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import Foundation

@objc class STMGarbageCollector:NSObject{
    
    static var unusedImages = Set<String>()
    
    static func removeUnusedImages(){
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            do {
                searchUnusedImages()
                if unusedImages.count > 0 {
                    let logMessage = String(format: "Deleting %i images",unusedImages.count)
                    STMLogger.shared().saveLogMessage(withText: logMessage, type:"important")
                }
                recheckUnusedImages()
                for unusedImage in unusedImages{
                    try FileManager.default.removeItem(atPath: STMFunctions.documentsDirectory()+"/"+unusedImage)
                    self.unusedImages.remove(unusedImage)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "unusedImageRemoved"), object: nil)
                }
            } catch let error as NSError {
                NSLog(error.description)
            }
        }
    }
    
    fileprivate static func recheckUnusedImages(){
        do {
            var usedImages = Set<String>()
            let document = STMSessionManager.shared().currentSession.document
            let photoFetchRequest = STMFetchRequest(entityName: NSStringFromClass(STMPicture))
            let photos = try document?.managedObjectContext.fetch(photoFetchRequest) as! [STMPicture]
            for image in photos{
                if let path = image.imagePath{
                    usedImages.insert(path)
                }
                if let resizedPath = image.resizedImagePath{
                    usedImages.insert(resizedPath)
                }
            }
            unusedImages = unusedImages.subtracting(usedImages)
        } catch let error as NSError {
            NSLog(error.description)
        }
    }
    
    static func searchUnusedImages(){
        do {
            unusedImages = Set<String>()
            var allImages = Set<String>()
            var usedImages = Set<String>()
            let document = STMSessionManager.shared().currentSession.document
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: STMFunctions.documentsDirectory())
            while let element = enumerator?.nextObject() as? String {
                if element.hasSuffix(".jpg") {
                    allImages.insert(element)
                }
            }
            let photoFetchRequest = STMFetchRequest(entityName: NSStringFromClass(STMPicture))
            let photos = try document?.managedObjectContext.fetch(photoFetchRequest) as! [STMPicture]
            for image in photos{
                if let path = image.imagePath{
                    usedImages.insert(path)
                }
                if let resizedPath = image.resizedImagePath{
                    usedImages.insert(resizedPath)
                }
            }
            unusedImages = allImages.subtracting(usedImages)
        } catch let error as NSError {
            NSLog(error.description)
        }
    }
}
