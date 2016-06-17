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
    
    private var currentGrouping:STMPhotoReportGrouping {
        let defaults = NSUserDefaults.standardUserDefaults()
        let key = "currentGrouping_\(STMAuthController().userID)"
        if defaults.integerForKey(key) == 1{
            return .Campaign
        }else{
            return .Outlet
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "showSettings":
            segue.destinationViewController.popoverPresentationController?.delegate = self
        case "showPhotoReportByOutlet":
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).selectedOutlet = sender as! STMOutlet
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).selectedCampaignGroup = self.selectedCampaignGroup
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).filterTVC = self
        case "showPhotoReportByCampaign":
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).selectedCampaign = sender as! STMCampaign
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).selectedCampaignGroup = self.selectedCampaignGroup
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).filterTVC = self
        default:
            break
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (currentGrouping) {
        case .Outlet:
            performSegueWithIdentifier("showPhotoReportByOutlet", sender: self.resultsController.objectAtIndexPath(indexPath))
        case .Campaign:
            performSegueWithIdentifier("showPhotoReportByCampaign", sender: self.resultsController.objectAtIndexPath(indexPath))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.performFetch()
    }
    
}
