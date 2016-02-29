//
//  STMOutletsTVC_Iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 26/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMOutletsTVC_iPhone: STMOutletsTVC {
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let outlet = self.resultsController.objectAtIndexPath(indexPath)
        performSegueWithIdentifier("showDebts", sender: outlet)
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "showDebts":
            (segue.destinationViewController as! STMDebtsPVC_iPhone).outlet = sender as? STMOutlet
        default:
        break
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func cashingProcessStart() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 600
    }
}
