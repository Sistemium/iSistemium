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
        do {
            for unusedImage in unusedImages{
                try NSFileManager.defaultManager().removeItemAtPath(STMFunctions.documentsDirectory()+"/"+unusedImage)
            }
            if unusedImages.count > 0 {
                NSLog("Deleted \(unusedImages.count) images")
            }
        } catch let error as NSError {
            NSLog(error.description)
        }
    }
    
    static func searchUnusedImages(){
        do {
            unusedImages = Set<String>()
            var allImages = Set<String>()
            var usedImages = Set<String>()
            let document = STMSessionManager.sharedManager().currentSession.document
            let fileManager = NSFileManager.defaultManager()
            let enumerator = fileManager.enumeratorAtPath(STMFunctions.documentsDirectory())
            while let element = enumerator?.nextObject() as? String {
                if element.hasSuffix(".jpg") {
                    allImages.insert(element)
                }
            }
            let photoFetchRequest = STMFetchRequest(entityName: NSStringFromClass(STMPicture))
            let photos = try document.managedObjectContext.executeFetchRequest(photoFetchRequest) as! [STMPicture]
            for image in photos{
                if let path = image.imagePath{
                    usedImages.insert(path)
                }
                if let resizedPath = image.resizedImagePath{
                    usedImages.insert(resizedPath)
                }
            }
            unusedImages = allImages.subtract(usedImages)
        } catch let error as NSError {
            NSLog(error.description)
        }
    }
}
