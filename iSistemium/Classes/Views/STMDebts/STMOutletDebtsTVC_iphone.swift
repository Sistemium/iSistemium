//
//  STMOutletDebtsTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 31/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit
import MessageUI

class STMOutletDebtsTVC_iphone: STMOutletDebtsTVC {
    override func showLongPressActionSheetFromView(view:UIView) {
    
        if view.isKindOfClass(UITableViewCell) {
            let cell = view as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            self.selectedDebt = self.resultsController.objectAtIndexPath(indexPath!) as! STMDebt

    //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
    //        delegate:self
    //        cancelButtonTitle:nil
    //        destructiveButtonTitle:nil
    //        otherButtonTitles:nil];
            
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL", comment: ""), destructiveButtonTitle: NSLocalizedString("DELETE", comment: ""))
            
            actionSheet.addButtonWithTitle(NSLocalizedString("COPY", comment: ""))
            
            if MFMailComposeViewController.canSendMail() {
            actionSheet.addButtonWithTitle(NSLocalizedString("SEND EMAIL", comment: ""))
            }
            
            if MFMessageComposeViewController.canSendText() {
            actionSheet.addButtonWithTitle(NSLocalizedString("SEND MESSAGE", comment: ""))
            }
            
            actionSheet.tag = 111
            
            actionSheet.showFromRect(cell.frame, inView: self.tableView, animated: true)
        
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
            return .Delete
    }
    

}
