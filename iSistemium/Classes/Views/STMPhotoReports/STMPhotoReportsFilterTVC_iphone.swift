//
//  STMPhotoReportsFilterTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMPhotoReportsFilterTVC_iphone:STMPhotoReportsFilterTVC,UIPopoverPresentationControllerDelegate{
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "showSettings":
            segue.destinationViewController.popoverPresentationController?.delegate = self
        default:
            break
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
}
