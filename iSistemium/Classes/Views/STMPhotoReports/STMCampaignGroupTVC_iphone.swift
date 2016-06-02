//
//  STMCampaignGroupTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 01/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMCampaignGroupTVC_iphone:STMCampaignGroupTVC{
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showFilterTVC", sender: (self.resultsController.objectAtIndexPath(indexPath) as! STMCampaignGroup).displayName())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! STMPhotoReportsFilterTVC).title = sender as? String
    }
    
}