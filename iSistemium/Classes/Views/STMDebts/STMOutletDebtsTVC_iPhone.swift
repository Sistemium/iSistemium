//
//  STMOutletDebtsTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 31/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit
import MessageUI

extension String {
    var first: String {
        return String(characters.prefix(1))
    }
    var last: String {
        return String(characters.suffix(1))
    }
    var uppercaseFirst: String {
        return first.uppercaseString + String(characters.dropFirst())
    }
}

class STMOutletDebtsTVC_iPhone: STMOutletDebtsTVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.registerNib(UINib(nibName: "STMThreeLinesAndCheckboxTVCell", bundle: nil), forCellReuseIdentifier: "debtDetailsCell")
    }
    
    override func showLongPressActionSheetFromView(view:UIView) {
        if view.isKindOfClass(UITableViewCell) {
            let cell = view as! UITableViewCell
            let indexPath = self.tableView.indexPathForCell(cell)
            self.selectedDebt = self.resultsController.objectAtIndexPath(indexPath!) as! STMDebt
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL", comment: ""), destructiveButtonTitle: nil)
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
    
    override func textLabelForDebt(debt: STMDebt!, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let debtSumString = numberFormatter().stringFromNumber(debt.calculatedSum)
        if debtSumString != nil{
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string: debtSumString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt.ndoc != nil{
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + debt.ndoc ,attributes:attributes as? [String : AnyObject]))
        }
        return text
    }
    
    override func detailTextLabelForDebt(debt: STMDebt!, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let debtSumOriginString = numberFormatter().stringFromNumber(debt.summOrigin)
        if debtSumOriginString != nil {
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumOriginString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let debtDate = dateFormatter().stringFromDate(debt.date)
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
    
    func messageTextLabelForDebt(debt: STMDebt!, var withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        if debt.dateE != nil{
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            var numberOfDays = STMFunctions.daysFromTodayToDate(debt.dateE)
            var dueDate : NSString
            switch numberOfDays.intValue{
            case 0:
                textColor = UIColor.purpleColor()
                dueDate = NSLocalizedString("TODAY", comment: "")
            case 1:
                dueDate = NSLocalizedString("TOMORROW", comment:"")
            case -1:
                textColor = UIColor.redColor()
                dueDate = NSLocalizedString("YESTERDAY", comment: "")
            default:
                let pluralType = STMFunctions.pluralTypeForCount(UInt(abs(numberOfDays.intValue)))
                let dateIsInPast = numberOfDays.intValue < 0
                if dateIsInPast {
                    let positiveNumberOfDays = -1 * numberOfDays.intValue
                    numberOfDays = NSNumber(int: positiveNumberOfDays)
                }
                dueDate = NSString(format: "%@ %@", numberOfDays, NSLocalizedString(pluralType.stringByAppendingString("DAYS"), comment: ""))
                if (dateIsInPast) {
                    textColor = UIColor.redColor()
                    dueDate = NSString(format: "%@ %@", NSLocalizedString("AGO", comment: ""), dueDate)
                }
            }
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let dueDateHeader = NSString(format: "%@: ", NSLocalizedString("DUE DATE", comment:""))
            text.appendAttributedString(NSAttributedString(string: dueDateHeader as String,attributes:attributes as? [String : AnyObject]))
            text.appendAttributedString(NSAttributedString(string: dueDate as String + " ", attributes:attributes as? [String : AnyObject]))
        }
        if debt.commentText != nil {
            font = UIFont.systemFontOfSize(14)
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let commentString = NSString(format:"(%@) ", debt.commentText)
            text.appendAttributedString(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        if debt.responsibility != nil {
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let customCell = cell as! STMThreeLinesAndCheckboxTVCell
        let debt = self.resultsController.objectAtIndexPath(indexPath)
        customCell.contentView.viewWithTag(1)?.removeFromSuperview()
        customCell.tintColor = STMConstants.ACTIVE_BLUE_COLOR
        customCell.accessoryType = .None
        customCell.titleLabel!.backgroundColor = UIColor.clearColor()
        customCell.detailLabel!.backgroundColor = UIColor.clearColor()
        customCell.checkboxView.viewWithTag(444)?.removeFromSuperview()
        if STMCashingProcessController.sharedInstance().state == .Running {
            var fillWidth: CGFloat = 0
            if debt.xid != nil && STMCashingProcessController.sharedInstance().debtsDictionary.allKeys.contains({$0 as? NSObject == debt.xid}) {
                let cashingSum = STMCashingProcessController.sharedInstance().debtsDictionary[debt.xid!!]![1]
                fillWidth = CGFloat(cashingSum.decimalNumberByDividingBy(debt.calculatedSum).doubleValue)
                customCell.accessoryType = .DetailButton
                let checkLabel = STMLabel(frame: customCell.checkboxView.bounds)
                checkLabel.adjustsFontSizeToFitWidth = true
                checkLabel.text = "✓"
                checkLabel.textColor = STMConstants.ACTIVE_BLUE_COLOR
                checkLabel.textAlignment = .Left
                checkLabel.tag = 444
                customCell.checkboxView.addSubview(checkLabel)
            } else {
                customCell.accessoryType = .None
            }
            if (fillWidth != 0) {
                fillWidth *= customCell.frame.size.width
                if (fillWidth < 10) {
                    fillWidth = 10
                }
                let rect = CGRectMake(0, 1, fillWidth, customCell.frame.size.height-2)
                let view = UIView(frame:rect)
                view.backgroundColor = STMConstants.STM_SUPERLIGHT_BLUE_COLOR
                view.tag = 1
                customCell.contentView.addSubview(view)
                customCell.contentView.sendSubviewToBack(view)
            }
        }
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("debtDetailsCell",forIndexPath:indexPath) as! STMThreeLinesAndCheckboxTVCell
        let debt = self.resultsController.objectAtIndexPath(indexPath)
        cell.titleLabel?.attributedText = self.textLabelForDebt(debt as! STMDebt, withFont:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabelForDebt(debt as! STMDebt, withFont:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(debt as! STMDebt, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .None
        self.addLongPressToCell(cell)
        cell.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.detailLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDebtDetails", sender: resultsController.objectAtIndexPath(indexPath) as! STMDebt)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "showDebtDetails"{
            (segue.destinationViewController as! STMCashingControlsVC_iPhone).selectedDebt = sender as! STMDebt
        }
    }
    
}

