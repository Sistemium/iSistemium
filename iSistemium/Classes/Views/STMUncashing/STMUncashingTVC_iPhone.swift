//
//  STMUncashingTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingTVC_iPhone: STMUncashingMasterTVC {
    
    private var cancelButton:STMBarButtonItem?
    
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
    
    override func uncashingProcessStart(){
//        self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
//        self.navigationItem.titleView = dateButton
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
//        selectedDate = NSDate()
//        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        self.setToolbarItems([flexibleSpace,UIBarButtonItem(customView: summLabel),flexibleSpace],animated: false)
//        showCashingSumLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton = STMBarButtonItem(title: NSLocalizedString("CANCEL", comment: ""), style: .Plain, target:STMCashingProcessController.sharedInstance(), action:"cancelCashingProcess")
        cancelButton!.tintColor = .redColor()
    }
    
}
