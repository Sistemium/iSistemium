//
//  STMOutletCashingVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMOutletCashingVC_iPhone: STMOutletCashingVC {

    // MARK: table view data
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STMCustom6TVCell",forIndexPath:indexPath) as! STMCustom6TVCell
        let cashing = self.resultsController.objectAtIndexPath(indexPath) as! STMCashing
        
        cell.titleLabel?.attributedText = self.textLabelForDebt(cashing, withFont:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .None
        cell.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.detailLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func textLabelForDebt(cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let cashingSumString = numberFormatter().stringFromNumber(cashing.summ)
        let debt = cashing.debt
        backgroundColor = UIColor.clearColor()
        textColor = UIColor.darkGrayColor()
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if cashingSumString != nil{
            text.appendAttributedString(NSAttributedString(string: cashingSumString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt?.ndoc != nil{
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + debt.ndoc ,attributes:attributes as? [String : AnyObject]))
        }
        return text
    }
    
    func detailTextLabelForDebt(cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let debt = cashing.debt
        let debtSumOriginString:String?
        if debt?.summOrigin == nil{
            debtSumOriginString = nil
        }else{
            debtSumOriginString = numberFormatter().stringFromNumber(debt.summOrigin)
        }
        backgroundColor = UIColor.clearColor()
        textColor = UIColor.darkGrayColor()
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if debtSumOriginString != nil{
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumOriginString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt?.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let debtDate = dateFormatter().stringFromDate(debt.date)
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("OF", comment: "") + " " + debtDate, attributes: attributes as? [String : AnyObject]))
        }
        return text
    }
    
    func messageTextLabelForDebt(cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let debt = cashing.debt
        if cashing.commentText != nil {
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.darkGrayColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let commentString = NSString(format:"(%@) ", cashing.commentText)
            text.appendAttributedString(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        if debt?.responsibility != nil {
            backgroundColor = UIColor.grayColor()
            textColor = UIColor.whiteColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let responsibilityString = NSString(format: "%@", debt.responsibility)
            text.appendAttributedString(NSAttributedString(string:responsibilityString as String, attributes:attributes as? [String : AnyObject]))
            text.appendAttributedString(NSAttributedString(string: " "))
        }
        return text
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 100
        tableView!.registerNib(UINib(nibName: "STMCustom6TVCell", bundle: nil), forCellReuseIdentifier: "STMCustom6TVCell")
    }
}
