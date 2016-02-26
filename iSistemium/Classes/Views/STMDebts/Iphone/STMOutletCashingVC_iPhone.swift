//
//  STMOutletCashingVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMOutletCashingVC_iPhone: STMOutletCashingVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 100
    }
    
    func textLabelForDebt(cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        backgroundColor = UIColor.clearColor()
        textColor = UIColor.blackColor()
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        text.appendAttributedString(NSAttributedString(string: cashing.debt.ndoc + " ",attributes:attributes as? [String : AnyObject]))
        if cashing.debt.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let debtDate = dateFormatter().stringFromDate(cashing.debt.date)
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("OF", comment: "") + " " + debtDate, attributes: attributes as? [String : AnyObject]))
        }
        return text
    }
    
    func detailTextLabelForDebt(cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        if cashing.debt.responsibility != nil {
            backgroundColor = UIColor.grayColor()
            textColor = UIColor.whiteColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let responsibilityString = NSString(format: "%@", cashing.debt.responsibility)
            text.appendAttributedString(NSAttributedString(string:responsibilityString as String + " ", attributes:attributes as? [String : AnyObject]))
            text.appendAttributedString(NSAttributedString(string: " "))
        }
        if cashing.commentText != nil {
            attributes = [NSFontAttributeName: font]
            text.appendAttributedString(NSAttributedString(string:"("+cashing.commentText+") ", attributes:attributes as? [String : AnyObject]))
        }
        let numberFormatter = STMFunctions.currencyFormatter
        let debtSumString = numberFormatter().stringFromNumber(cashing.summ)
        if debtSumString != nil {
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string:NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumString!, attributes: attributes as? [String : AnyObject]))
        }
        return text
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cashingDetailsCell",forIndexPath:indexPath)
        let cashing = self.resultsController.objectAtIndexPath(indexPath) as! STMCashing
        cell.textLabel!.attributedText = self.textLabelForDebt(cashing, withFont:cell.textLabel!.font)
        cell.detailTextLabel!.attributedText = self.detailTextLabelForDebt(cashing, withFont:cell.detailTextLabel!.font)
        cell.selectionStyle = .None
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }

}
