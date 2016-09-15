//
//  STMPhotoReportsDetailTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMPhotoReportsDetailTVC_iphone:STMPhotoReportsDetailTVC,UIPopoverPresentationControllerDelegate{
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if self.selectedCampaign != nil || self.selectedOutlet != nil{
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        switch segue.identifier {
        case "cameraButtonPressed"?:
            (segue.destinationViewController as! STMPhotoReportAddPhotoTVC).parentVC = self
        case "showSettings"?:
            segue.destinationViewController.popoverPresentationController?.delegate = self
        default:
            break
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}
