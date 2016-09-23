//
//  STMOutletDebtsTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 31/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit
import MessageUI

class STMOutletDebtsTVC_iPhone: STMOutletDebtsTVC {
    
    // MARK: Override superclass
    
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
    
    // MARK: Table view data
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rez = super.tableView(tableView, numberOfRowsInSection: section)
        if rez == 0 {
            self.parentVC?.cashingButton.enabled = false
        }else{
            self.parentVC?.cashingButton.enabled = true
        }
        return rez
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("debtDetailsCell",forIndexPath:indexPath) as! STMThreeLinesAndCheckboxTVCell
        let debt = self.resultsController.objectAtIndexPath(indexPath)
        cell.titleLabel?.attributedText = self.textLabelForDebt(debt as! STMDebt, withFont:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabelForDebt(debt as! STMDebt, withFont:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(debt as! STMDebt, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .None
        self.addLongPressToCell(cell)
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let customCell = cell as! STMThreeLinesAndCheckboxTVCell
        let debt = self.resultsController.objectAtIndexPath(indexPath) as! STMDebt
        customCell.contentView.viewWithTag(1)?.removeFromSuperview()
        customCell.tintColor = STMSwiftConstants.ACTIVE_BLUE_COLOR
        customCell.accessoryType = .None
        customCell.titleLabel!.backgroundColor = UIColor.clearColor()
        customCell.detailLabel!.backgroundColor = UIColor.clearColor()
        customCell.checkboxView.viewWithTag(444)?.removeFromSuperview()
        
        if STMCashingProcessController.sharedInstance().state == .Running {
            
            var fillWidth: CGFloat = 0
            let debtsDictionary: NSDictionary = STMCashingProcessController.sharedInstance().debtsDictionary
            
            if debt.xid != nil && debtsDictionary.allKeys.contains({$0 as? NSObject == debt.xid}) {
                
                let debtValues: NSArray = debtsDictionary[debt.xid!]! as! NSArray
                let cashingSum = debtValues[1]
                fillWidth = CGFloat(cashingSum.decimalNumberByDividingBy(debt.calculatedSum ?? 0).doubleValue)
                
                let checkLabel = STMLabel(frame: customCell.checkboxView.bounds)
                checkLabel.adjustsFontSizeToFitWidth = true
                checkLabel.text = "✓"
                checkLabel.textColor = STMSwiftConstants.ACTIVE_BLUE_COLOR
                checkLabel.textAlignment = .Left
                checkLabel.tag = 444
                customCell.checkboxView.addSubview(checkLabel)

                customCell.accessoryType = .DetailButton

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
                view.backgroundColor = STMSwiftConstants.STM_SUPERLIGHT_BLUE_COLOR
                view.tag = 1
                customCell.contentView.addSubview(view)
                customCell.contentView.sendSubviewToBack(view)
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDebtDetails", sender: resultsController.objectAtIndexPath(indexPath) as! STMDebt)
    }
    
    override func textLabelForDebt(debt: STMDebt!, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let debtSumString = numberFormatter().stringFromNumber(debt.calculatedSum ?? 0)
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
        if let ndoc = debt.ndoc{
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + ndoc ,attributes:attributes as? [String : AnyObject]))
        }
        return text
    }
    
    
    override func detailTextLabelForDebt(debt: STMDebt!, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        if let summOrigin = debt.summOrigin {
            let debtSumOriginString = numberFormatter().stringFromNumber(summOrigin)
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
            let debtDate = dateFormatter().stringFromDate(debt.date!)
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
    
    func messageTextLabelForDebt(debt: STMDebt!, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        if debt.dateE != nil{
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            var numberOfDays = STMFunctions.daysFromTodayToDate(debt.dateE!)
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
            backgroundColor = UIColor.clearColor()
            textColor = UIColor.blackColor()
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let commentString = NSString(format:"(%@) ", debt.commentText!)
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
            let responsibilityString = NSString(format: "%@", debt.responsibility!)
            text.appendAttributedString(NSAttributedString(string:responsibilityString as String, attributes:attributes as? [String : AnyObject]))
            text.appendAttributedString(NSAttributedString(string: " "))
        }
        return text
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "showDebtDetails"{
            (segue.destinationViewController as! STMCashingControlsVC_iPhone).selectedDebt = sender as! STMDebt
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.registerNib(UINib(nibName: "STMThreeLinesAndCheckboxTVCell", bundle: nil), forCellReuseIdentifier: "debtDetailsCell")
    }
}

