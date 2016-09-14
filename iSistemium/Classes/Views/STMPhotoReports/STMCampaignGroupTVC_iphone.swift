//
//  STMCampaignGroupTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 01/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMCampaignGroupTVC_iphone:STMCampaignGroupTVC, UIPopoverPresentationControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBOutlet weak var showAllButton: UIBarButtonItem!{
        didSet{
            showAllButton.title = NSLocalizedString(showAllButton.title!, comment: "")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showFilterTVC", sender: (self.resultsController.objectAtIndexPath(indexPath)))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "showFilterTVC":
            (segue.destinationViewController as! STMPhotoReportsFilterTVC).title = (sender as! STMCampaignGroup).displayName()
            let campaignGroup = (sender as! STMCampaignGroup)
            (segue.destinationViewController as! STMPhotoReportsFilterTVC).selectedCampaignGroup = campaignGroup;
        case "showSettings":
            segue.destinationViewController.popoverPresentationController?.delegate = self
        default:
            break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        if let _ = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
}