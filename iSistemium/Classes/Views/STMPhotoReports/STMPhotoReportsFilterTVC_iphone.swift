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
        case "showPhotoReportByCampaign":
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).selectedCampaign = sender as! STMCampaign
            (segue.destinationViewController as! STMPhotoReportsDetailTVC_iphone).selectedCampaignGroup = self.selectedCampaignGroup
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
    
//    - (void)tableView:(UITableView *)tableView didSelectOutletAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    
//    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
//    
//    if ([outlet isEqual:self.splitVC.detailVC.selectedOutlet]) {
//    
//    self.splitVC.detailVC.selectedOutlet = nil;
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    } else {
//    
//    self.splitVC.detailVC.selectedOutlet = outlet;
//    
//    }
//    
//    }
//
//    - (void)tableView:(UITableView *)tableView didSelectCampaignAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    
//    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
//    
//    if ([campaign isEqual:self.splitVC.detailVC.selectedCampaign]) {
//    
//    self.splitVC.detailVC.selectedCampaign = nil;
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    selectedCampaignGroup
//    } else {
//    
//    self.splitVC.detailVC.selectedCampaign = campaign;
//    
//    }
//    
//    }
    
}
