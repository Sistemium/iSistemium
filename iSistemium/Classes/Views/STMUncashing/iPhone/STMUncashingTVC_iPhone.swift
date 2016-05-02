//
//  STMUncashingTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingTVC_iPhone: STMUncashingMasterTVC {
    
    // MARK: Superclass override
    
    override func uncashingProcessStart(){
    }
    
    // MARK: Table view data
    
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
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "showUncashing":
            (segue.destinationViewController as! STMUncashingDetailsTVC).uncashing = sender as? STMUncashing
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            if sender != nil{
                if let destination = segue.destinationViewController as? STMUncashingDetailsTVC{
                    destination.title = NSLocalizedString("HAND OVER", comment: "").dropLast
                    if let date = (sender as! STMUncashing).date {
                        destination.title! += " (" + dateFormatter.stringFromDate(date) + ")"
                    }
                }
            }else{
                (segue.destinationViewController as! STMUncashingDetailsTVC).title = NSLocalizedString("ON HAND", comment: "").dropLast
            }
        default:
            break
        }
    }
    
    // MARK: View lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setToolbarHidden(true, animated: true)
    }
}
