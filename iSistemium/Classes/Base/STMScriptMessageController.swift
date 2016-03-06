//
//  STMScriptMessageController.swift
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import Foundation
import WebKit

let k_WK_SCRIPT_MESSAGE_FIND = "find"
let k_WK_SCRIPT_MESSAGE_FIND_ALL = "findAll"


class STMScriptMessageController: NSObject {
    
    @available(iOS 8.0, *)

    class func processScriptMessage(scriptMessage: WKScriptMessage, error: NSErrorPointer) -> NSPredicate? {
    
        guard let body: Dictionary = scriptMessage.body as? [String: AnyObject] else {
            errorWithMessage(error, errorMessage: "message body is not a Dictionary")
            return nil
        }
        
        guard var entityName: String = body["entity"] as? String else {
            errorWithMessage(error, errorMessage: "message body have no entity name")
            return nil
        }
        
        entityName = "STM" + entityName
        
        guard STMObjectsController.localDataModelEntityNames().contains(entityName) else {
            errorWithMessage(error, errorMessage: "local data model have no entity with name \(entityName)")
            return nil
        }
        
        let name: String = scriptMessage.name

        switch name {
            
            case k_WK_SCRIPT_MESSAGE_FIND:
                
                guard let xid: NSData? = STMFunctions.xidDataFromXidString(body["id"] as? String) else {
                    errorWithMessage(error, errorMessage: "where is no xid in \(k_WK_SCRIPT_MESSAGE_FIND) script message")
                    return nil
                }
                
                return predicateForScriptMessage(entityName, filter: ["xid": xid!], whereFilter: nil, error: error)
            
            case k_WK_SCRIPT_MESSAGE_FIND_ALL:
                
                guard let filter: [String: AnyObject]? = body["filter"] as? [String: AnyObject] else {
                    print("filter section malformed")
                    break
                }
                
                guard let whereFilter: [String: [String: AnyObject]]? = body["where"] as? [String: [String: AnyObject]] else {
                    print("whereFilter section malformed")
                    break
                }
                
                return predicateForScriptMessage(entityName, filter: filter, whereFilter: whereFilter, error: error)
                
            default: break
            
        }

        errorWithMessage(error, errorMessage: "unknown script message with name \(name)")
        return nil
        
    }

    class func predicateForScriptMessage(entityName: String, filter: [String: AnyObject]?, whereFilter: [String: [String: AnyObject]]?, error: NSErrorPointer) -> NSPredicate {
        
        var filterDictionary: [String: [String: AnyObject]] = (whereFilter != nil) ? whereFilter! : [String: [String: AnyObject]]();
        
        if (filter != nil) {
            for key in filter!.keys {
                filterDictionary[key] = ["==": filter![key]!]
            }
        }
        
        let subpredicates: [NSPredicate] = subpredicatesForFilterDictionaryWithEntityName(entityName, filterDictionary: filterDictionary)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        
    }

    class func subpredicatesForFilterDictionaryWithEntityName(entityName: String, var filterDictionary: [String: [String: AnyObject]]) -> [NSPredicate] {
        
        let entityDescription: STMEntityDescription = STMEntityDescription.entityForName(entityName, inManagedObjectContext: currentContext())
        
        // filter only by attributes
        // filter by relationships is not ready yet
        
        //    let properties: [String : NSPropertyDescription] = entityDescription.propertiesByName
        let attributes: [String : NSAttributeDescription] = entityDescription.attributesByName
        //    let relationships: [String : NSRelationshipDescription] = entityDescription.relationshipsByName

        var subpredicates: [NSPredicate] = []
        
        for key in filterDictionary.keys {
            
            guard attributes.keys.contains(key) else {
                print("\(entityName) have not attribute \(key)")
                break
            }
            
            guard let className: String = attributes[key]!.attributeValueClassName else {
                print("\(entityName) have no class type for key \(key)")
                break
            }
            
            var arguments: [String: AnyObject] = filterDictionary[key]!

            let comparisonOperators: [String] = ["==", "!=", ">=", "<=", ">", "<"]

            for compOp in arguments.keys {

                guard comparisonOperators.contains(compOp) else {
                    print("comparison operator should be '==', '!=', '>=', '<=', '>' or '<', not '\(compOp)'")
                    break
                }

                guard var value: AnyObject = arguments[compOp] else {
                    print("have no value for comparison operator '\(compOp)'")
                    break
                }

                value = normalizeValue(value as! String, className: className)
                
                let subpredicateString: String = "\(key) \(compOp) %@"

                let subpredicate: NSPredicate = NSPredicate(format: subpredicateString, argumentArray: [value])

                subpredicates.append(subpredicate)

            }

        }
        
        return subpredicates
        
    }

    class func normalizeValue(value: String, className: String) -> AnyObject {
        
        switch className {
            
            case NSStringFromClass(NSNumber)    :   return NSNumberFormatter().numberFromString(value)!
                
            case NSStringFromClass(NSDate)      :   return STMDateFormatter().dateFromString(value)!
                
            case NSStringFromClass(NSData)      :   return STMFunctions.dataFromString(value)
                
            default                             :   return value
            
        }
        
    }

    class func currentContext() -> NSManagedObjectContext {
        
        return STMSessionManager.sharedManager().currentSession.document.managedObjectContext
        
    }
    
    class func errorWithMessage(error: NSErrorPointer, errorMessage: String) {
        
        let bundleId: String? = NSBundle.mainBundle().bundleIdentifier
        
        if (bundleId != nil && error != nil) {
         
            error.memory = NSError(domain: bundleId!, code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            
        }
        
    }
    
}
