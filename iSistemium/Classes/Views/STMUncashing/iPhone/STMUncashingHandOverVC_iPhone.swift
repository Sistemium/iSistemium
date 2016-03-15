//
//  STMUncashingHandOverVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 14/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMUncashingHandOverVC_iPhone: STMUncashingHandOverVC, UIPopoverPresentationControllerDelegate {
    // MARK: Superclass override
    
    override func customInit() {
    super.customInit()
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.setHidesBackButton(false, animated: false)
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .Done, target: STMUncashingProcessController.sharedInstance(), action: "checkUncashing")
    self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func showInfoPopover(){
        let content = self.storyboard!.instantiateViewControllerWithIdentifier("uncashingInfoPopover") as! STMUncashingInfoVC
        content.sum = self.uncashingSum
        content.type = self.uncashingType
        content.comment = self.commentText
        content.image = self.pictureImage
        content.place = self.currentUncashingPlace
        content.modalPresentationStyle = .Popover
        let popover = content.popoverPresentationController
        content.preferredContentSize = CGSizeMake(388,205)
        popover!.delegate = self
        popover!.sourceView = self.navigationController?.navigationBar
        let frame = (self.navigationItem.rightBarButtonItem!.valueForKey("view") as! UIView).frame
        popover!.sourceRect = frame
        self.presentViewController(content, animated: true, completion: nil)
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        STMUncashingProcessController.sharedInstance().uncashingType = nil
    }
}
