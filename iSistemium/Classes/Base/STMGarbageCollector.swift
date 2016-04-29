//
//  STMGarbageCollector.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 19/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import Foundation

@objc class STMGarbageCollector:NSObject{
    
    static func removeUnusedImages(){
        do {
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
            let photoFetchRequest = STMFetchRequest(entityName: NSStringFromClass(STMPhoto))
            let photos = try document.managedObjectContext.executeFetchRequest(photoFetchRequest) as! [STMPhoto]
            for image in photos{
                if let path = image.imagePath{
                    usedImages.insert(path)
                }
                if let resizedPath = image.resizedImagePath{
                    usedImages.insert(resizedPath)
                }
            }
            let unusedImages = allImages.subtract(usedImages)
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
    
}
