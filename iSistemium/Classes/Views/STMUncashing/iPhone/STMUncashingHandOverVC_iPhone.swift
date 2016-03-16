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
    private var infoPopover:STMUncashingInfoVC_iPhone?
    
    override func customInit() {
        super.customInit()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .Done, target: STMUncashingProcessController.sharedInstance(), action: "checkUncashing")
        self.navigationController?.setToolbarHidden(true, animated: true)
        STMUncashingProcessController.sharedInstance().uncashingType = nil
        STMUncashingProcessController.sharedInstance().pictureImage = nil
    }
    
    override func showInfoPopover(){
        let content = self.storyboard!.instantiateViewControllerWithIdentifier("uncashingInfoPopover") as! STMUncashingInfoVC_iPhone
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
        content.parentVC = self
        self.presentViewController(content, animated: true, completion: nil)
        infoPopover = content
    }
    
    override func showImagePickerForSourceType(imageSourceType:UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(imageSourceType) {
        self.selectedSourceType = imageSourceType
        self.presentViewController(self.imagePickerController, animated:true){
            self.view.addSubview(self.spinnerView)
            }
        }
    }
    
    override func dismissInfoPopover() {
        infoPopover?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
