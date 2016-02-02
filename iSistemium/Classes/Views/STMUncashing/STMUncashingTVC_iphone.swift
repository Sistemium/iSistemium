//
//  STMUncashingTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingTVC_iphone: STMUncashingMasterTVC {
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.section == 0) {
            performSegueWithIdentifier("showUncashing", sender: nil)
        } else {
            let sectionInfo = self.resultsController.sections![indexPath.section-1]
            let uncashing = sectionInfo.objects![indexPath.row];
            performSegueWithIdentifier("showUncashing", sender: uncashing)
        }
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        cell?.tintColor = .whiteColor()
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "showUncashing":
            (segue.destinationViewController as! STMUncashingDetailsTVC).uncashing = sender as? STMUncashing
        default:
            break
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = true
    }
    
}
