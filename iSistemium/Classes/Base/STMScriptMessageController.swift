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

@available(iOS 8.0, *)

func processScriptMessage(scriptMessage: WKScriptMessage) -> NSPredicate? {

    var predicate: NSPredicate? = nil
    
    let name: String = scriptMessage.name
    
    if let body: Dictionary = scriptMessage.body as? [String: AnyObject] {
        
        print([name, body])
        
        if let entityName: String = body["entity"] as? String {
        
            if STMObjectsController.localDataModelEntityNames().contains(entityName) {
                
//                let options: Dictionary? = body["options"] as? Dictionary<String, AnyObject>

                switch name {
                    
                    case k_WK_SCRIPT_MESSAGE_FIND:
                        if let xid: NSData? = STMFunctions.xidDataFromXidString(body["id"] as? String) {
                            
                            predicate = predicateForScriptMessage(entityName, filter: ["xid": xid!], whereFilter: nil)
                            
                        } else {
                            print("where is no xid in \(k_WK_SCRIPT_MESSAGE_FIND) script message")
                        }
                    
                    case k_WK_SCRIPT_MESSAGE_FIND_ALL:
                        let filter: Dictionary? = body["filter"] as? [String: AnyObject]
                        let whereFilter: Dictionary? = body["where"] as? [String: AnyObject]

                        predicate = predicateForScriptMessage(entityName, filter: filter, whereFilter: whereFilter)
                    
                    default: break
                    
                }
                
            } else {
                print("local data model have no entity with name \(entityName)")
            }

        } else {
            print("message body have no entity name")
        }
        
    } else {
        print("message body is not a Dictionary")
    }
    
    return predicate
    
}

func predicateForScriptMessage(entityName: String, filter: [String: AnyObject]?, whereFilter: [String: AnyObject]?) -> NSPredicate {
    
    let entityDescription: STMEntityDescription = STMEntityDescription.entityForName(entityName, inManagedObjectContext: currentContext())
    let entityAttributes: [String : NSAttributeDescription] = entityDescription.attributesByName

    var subpredicates: [NSPredicate] = []

    if (filter != nil) {
        
        let filterKeys: [String] = checkKeysForEntity(entityName, keys: filter!.keys)
        
        for key in filterKeys {

            guard var value: AnyObject = filter![key] else {
                print("have no value for key \(key)")
                break
            }

            if value is NSNumber { value = value.stringValue }
            
            guard value is String else {
                print("value \(value) for key \(key) is not supported")
                break
            }

            guard let className: String = entityAttributes[key]?.attributeValueClassName else {
                print("have no class type for key \(key)")
                break
            }
            
            value = normalizeValue(value, className: className)
            
            let subpredicateString: String = "\(key) == %@"
            
            let subpredicate: NSPredicate = NSPredicate(format: subpredicateString, argumentArray: [value])
            
            subpredicates.append(subpredicate)
            
        }
        
    }
    
    if (whereFilter != nil) {
        
        let filterKeys: [String] = checkKeysForEntity(entityName, keys: whereFilter!.keys)
        
        for key in filterKeys {
            
            guard let className: String = entityAttributes[key]?.attributeValueClassName else {
                print("have no class type for key \(key)")
                break
            }
            
            guard let arguments: Dictionary = whereFilter![key] as? [String: AnyObject] else {
                print("arguments is not a dictionary")
                break
            }
            
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
                
                if value is NSNumber { value = value.stringValue }
                
                guard value is String else {
                    print("value \(value) for comparison operator '\(compOp)' is not supported")
                    break
                }
                
                value = normalizeValue(value, className: className)
                
                let subpredicateString: String = "\(key) \(compOp) %@"
                
                let subpredicate: NSPredicate = NSPredicate(format: subpredicateString, argumentArray: [value])
                
                subpredicates.append(subpredicate)

            }
            
        }

    }
    
    return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    
}

func checkKeysForEntity(entityName: String, keys: LazyMapCollection<[String: AnyObject], String>) -> [String] {
    
    let entityDescription: STMEntityDescription = STMEntityDescription.entityForName(entityName, inManagedObjectContext: currentContext())
    
// filter only by attributes
// filter by relationships is not ready yet

//    let properties: [String : NSPropertyDescription] = entityDescription.propertiesByName
    let attributes: [String : NSAttributeDescription] = entityDescription.attributesByName
//    let relationships: [String : NSRelationshipDescription] = entityDescription.relationshipsByName

    var resultKeys: [String] = []

    for key in keys {
        
        if attributes.keys.contains(key) {
            resultKeys.append(key)
        } else {
            print("\(entityName) have not attribute \(key)")
        }
        
    }
    
    return resultKeys

}

func normalizeValue(var value: AnyObject, className: String) -> AnyObject {
    
    switch className {
        
        case NSStringFromClass(NSNumber)    :   value = NSNumberFormatter().numberFromString(value as! String)!
            
        case NSStringFromClass(NSDate)      :   value = STMDateFormatter().dateFromString(value as! String)!
            
        case NSStringFromClass(NSData)      :   value = STMFunctions.dataFromString(value as! String)
        
        default: break
        
    }

    return value
    
}

func currentContext() -> NSManagedObjectContext {
    
    return STMSessionManager.sharedManager().currentSession.document.managedObjectContext
    
}
