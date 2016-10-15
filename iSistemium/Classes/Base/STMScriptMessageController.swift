//
//  STMScriptMessageController.swift
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import Foundation
import WebKit


class STMScriptMessageController: NSObject {
    
    @available(iOS 8.0, *)

    class func predicateForScriptMessage(_ scriptMessage: WKScriptMessage, error: NSErrorPointer) -> NSPredicate? {
    
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
            
            case STMSwiftConstants.ScriptMessageNames.WK_SCRIPT_MESSAGE_FIND:
                
                guard let xid: Data? = STMFunctions.xidData(fromXidString: body["id"] as? String) else {
                    errorWithMessage(error, errorMessage: "where is no xid in \(STMSwiftConstants.ScriptMessageNames.WK_SCRIPT_MESSAGE_FIND) script message")
                    return nil
                }
                
                return predicateForFilters(entityName, filter: ["xid": xid! as AnyObject], whereFilter: nil, error: error)
            
            case STMSwiftConstants.ScriptMessageNames.WK_SCRIPT_MESSAGE_FIND_ALL:
                
                guard let filter: [String: AnyObject]? = body["filter"] as? [String: AnyObject] else {
                    print("filter section malformed")
                    break
                }
                
                guard let whereFilter: [String: [String: AnyObject]]? = body["where"] as? [String: [String: AnyObject]] else {
                    print("whereFilter section malformed")
                    break
                }
                
                return predicateForFilters(entityName, filter: filter, whereFilter: whereFilter, error: error)
                
            default: break
            
        }

        errorWithMessage(error, errorMessage: "unknown script message with name \(name)")
        return nil
        
    }

    class func predicateForFilters(_ entityName: String, filter: [String: AnyObject]?, whereFilter: [String: [String: AnyObject]]?, error: NSErrorPointer) -> NSPredicate {
        
        var filterDictionary: [String: [String: AnyObject]] = (whereFilter != nil) ? whereFilter! : [String: [String: AnyObject]]();
        
        if (filter != nil) {
            for key in filter!.keys {
                filterDictionary[key] = ["==": filter![key]!]
            }
        }
        
        let subpredicates: [NSPredicate] = subpredicatesForFilterDictionaryWithEntityName(entityName, filterDictionary: filterDictionary)
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        
    }

    class func subpredicatesForFilterDictionaryWithEntityName(_ entityName: String, filterDictionary: [String: [String: AnyObject]]) -> [NSPredicate] {
        var filterDictionary = filterDictionary
        let entityDescription: STMEntityDescription = STMEntityDescription.entity(forEntityName: entityName, in: currentContext())
        
        let properties: [String : NSPropertyDescription] = entityDescription.propertiesByName
        let attributes: [String : NSAttributeDescription] = entityDescription.attributesByName
        let relationships: [String : NSRelationshipDescription] = entityDescription.relationshipsByName

        var subpredicates: [NSPredicate] = []
        
        for key in filterDictionary.keys {
            
            var localKey: String = key;
            
            if key == "id" { localKey = "xid" }
            if key == "ts" { localKey = "deviceTs" }
            
            guard properties.keys.contains(localKey) else {
                print("\(entityName) have not property \(localKey)")
                continue
            }
            
            let isAttribute: Bool = attributes.keys.contains(localKey);
            let isRelationship: Bool = relationships.keys.contains(localKey);
            
            guard isAttribute == true || isRelationship == true else {
                print("unknown kind of property '\(localKey)'")
                continue
            }

            let arguments: [String: AnyObject] = filterDictionary[key]!

            let comparisonOperators: [String] = ["==", "!=", ">=", "<=", ">", "<"]

            for compOp in arguments.keys {

                guard comparisonOperators.contains(compOp) else {
                    print("comparison operator should be '==', '!=', '>=', '<=', '>' or '<', not '\(compOp)'")
                    continue
                }
                
//                guard var value: AnyObject? = arguments[compOp] else {
//                    print("have no value for comparison operator '\(compOp)'")
//                    continue
//                }

                var value: AnyObject? = arguments[compOp]
                
                if localKey.lowercased().hasSuffix("uuid") || localKey.lowercased().hasSuffix("xid") || isRelationship {

                    guard value is String else {
                        print("value is not a String, but it should be to get xid or uuid value")
                        continue
                    }
                    
                    value = value?.replacingOccurrences(of: "-", with: "")
                    
                }
                
                if isAttribute {
                    
                    guard let className: String = attributes[localKey]!.attributeValueClassName else {
                        print("\(entityName) have no class type for key \(localKey)")
                        continue
                    }
                    
                    value = normalizeValue(value, className: className)

                } else if isRelationship {
                    
                    guard ((relationships[localKey]?.isToMany) == false) else {
                        print("relationship \(localKey) is toMany")
                        continue
                    }
                    
                    guard let className: String = relationships[localKey]!.destinationEntity?.name else {
                        print("\(entityName) have no class type for key \(localKey)")
                        continue
                    }

                    value = relationshipObjectForValue(value, className: className)
                    
                }
                
                var subpredicate: NSPredicate
                
                if value != nil {
                
                    let subpredicateString: String = "\(localKey) \(compOp) %@"
                    subpredicate = NSPredicate(format: subpredicateString, argumentArray: [value!])

                } else {
                    
                    let subpredicateString: String = "\(localKey) \(compOp) nil"
                    subpredicate = NSPredicate(format: subpredicateString, argumentArray: nil)

                }
                
                subpredicates.append(subpredicate)

            }

        }
        
        return subpredicates
        
    }

    class func normalizeValue(_ value: AnyObject?, className: String) -> AnyObject? {
        
        var value = value
        
        guard value != nil else {
            return nil
        }
        
        if value is NSNumber { value = value!.stringValue as AnyObject? }
        
        switch className {
            
            case NSStringFromClass(NSNumber)    :   return NumberFormatter().number(from: value as! String)!
                
            case NSStringFromClass(Date) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass)      :   return STMFunctions.dateFormatter().date(from: value as! String)! as AnyObject?
                
            case NSStringFromClass(Data) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass) as! (AnyClass)      :   return STMFunctions.data(from: value as! String) as AnyObject?
                
            default                             :   return value
            
        }
        
    }
    
    class func relationshipObjectForValue(_ value: AnyObject?, className: String) -> AnyObject? {
        
        var value = value
        
        guard value is String else {
            print("relationship value is not a String, can not get xid")
            return nil
        }
        
        value = STMObjectsController.object(forXid: STMFunctions.data(from: value as! String), entityName: className)
        
        return value

    }

    class func currentContext() -> NSManagedObjectContext {
        
        return STMSessionManager.shared().currentSession.document.managedObjectContext
        
    }
    
    class func errorWithMessage(_ error: NSErrorPointer?, errorMessage: String) {
        
        let bundleId: String? = Bundle.main.bundleIdentifier
        
        if (bundleId != nil && error != nil) {
         
            error??.pointee = NSError(domain: bundleId!, code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            
        }
        
    }
    
}
