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
    fileprivate var infoPopover:STMUncashingInfoVC_iPhone?
    
    override func customInit() {
        super.customInit()
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .done, target: STMUncashingProcessController.sharedInstance(), action: #selector(STMUncashingProcessController.checkUncashing))
        self.navigationController?.setToolbarHidden(true, animated: true)
        STMUncashingProcessController.sharedInstance().uncashingType = nil
        STMUncashingProcessController.sharedInstance().pictureImage = nil
    }
    
    override func showInfoPopover(){
        self.commentTextView?.endEditing(true)
        let content = self.storyboard!.instantiateViewController(withIdentifier: "uncashingInfoPopover") as! STMUncashingInfoVC_iPhone
        content.sum = self.uncashingSum
        content.type = self.uncashingType
        content.comment = self.commentText
        content.image = self.pictureImage
        content.place = self.currentUncashingPlace
        content.modalPresentationStyle = .popover
        let popover = content.popoverPresentationController
        popover!.delegate = self
        popover!.sourceView = self.navigationController?.navigationBar
        let frame = (self.navigationItem.rightBarButtonItem!.value(forKey: "view") as! UIView).frame
        popover!.sourceRect = frame
        content.parentVC = self
        self.present(content, animated: true, completion: nil)
        infoPopover = content
    }
    
    override func showImagePicker(for imageSourceType:UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(imageSourceType) {
        self.selectedSourceType = imageSourceType
        self.present(self.imagePickerController, animated:true){
            self.view.addSubview(self.spinnerView)
            }
        }
    }
    
    override func dismissInfoPopover() {
        infoPopover?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for PC: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
