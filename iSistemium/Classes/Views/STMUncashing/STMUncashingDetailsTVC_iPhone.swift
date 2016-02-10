//
//  STMUncashingDetailsTVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 09/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMUncashingDetailsTVC_iPhone: STMUncashingDetailsTVC, UIPopoverPresentationControllerDelegate {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = false
    }
    
    override func showUncashingInfoPopover(){
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("uncashingInfoPopover") as! STMUncashingInfoVC
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(388,205)
        popover!.delegate = self
        popover!.sourceView = self.view
        let frame = (self.infoLabel!.valueForKey("view") as! UIView).frame
        popover!.sourceRect = frame
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    
}
