//
//  STMOutletsTVC_Iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 26/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMOutletsTVC_Iphone: STMOutletsTVC {
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let outlet = self.resultsController.objectAtIndexPath(indexPath)
        performSegueWithIdentifier("showDebts", sender: outlet)
        return indexPath
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!{
        case "showDebts":
            (segue.destinationViewController as! STMDebtsPVC_Iphone).outlet = sender as? STMOutlet
        default:
        break
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.toolbarHidden = true
    }
}
