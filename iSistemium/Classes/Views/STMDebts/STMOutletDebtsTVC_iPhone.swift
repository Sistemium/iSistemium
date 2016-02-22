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
        let numberFormatter = STMFunctions.currencyFormatter
        let debtSumString = numberFormatter().stringFromNumber(debt.calculatedSum)
        if debtSumString != nil {
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
            text.appendAttributedString(NSAttributedString(string: debt.ndoc + " ",attributes:attributes as? [String : AnyObject]))
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
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.appendAttributedString(NSAttributedString(string: "\n" + NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumString!))
            return text
        }else{
            return nil
        }
    }
    
    override func detailTextLabelForDebt(debt: STMDebt!, var withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
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
            text.appendAttributedString(NSAttributedString(string: dueDate as String, attributes:attributes as? [String : AnyObject]))
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
            let commentString = NSString(format:"(%@)", debt.commentText)
            text.appendAttributedString(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        return text
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let debt = self.resultsController.objectAtIndexPath(indexPath)
        cell.contentView.viewWithTag(1)?.removeFromSuperview()
        cell.tintColor = STMConstants.ACTIVE_BLUE_COLOR
        cell.accessoryType = .None
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.detailTextLabel!.backgroundColor = UIColor.clearColor()
        if STMCashingProcessController.sharedInstance().state == .Running {
            var fillWidth: CGFloat = 0
            if debt.xid != nil && STMCashingProcessController.sharedInstance().debtsDictionary.allKeys.contains({$0 as? NSObject == debt.xid}) {
                let cashingSum = STMCashingProcessController.sharedInstance().debtsDictionary[debt.xid!!]![1]
                fillWidth = CGFloat(cashingSum.decimalNumberByDividingBy(debt.calculatedSum).doubleValue)
                cell.accessoryView = nil
                cell.accessoryType = .DetailButton
                cell.imageView?.image = UIImage(named: "checkmark_filled")
                let itemSize:CGSize = CGSizeMake(10, 10)
                UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
                let imageRect : CGRect = CGRectMake(0, 0, itemSize.width , itemSize.height )
                cell.imageView!.image?.drawInRect(imageRect)
                cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            } else {
                cell.accessoryView = UIView(frame: CGRectMake(0, 0, 35, 35))
                cell.accessoryType = .None
            }
            if (fillWidth != 0) {
                fillWidth *= cell.frame.size.width
                if (fillWidth < 10) {
                    fillWidth = 10
                }
                let rect = CGRectMake(0, 1, fillWidth, cell.frame.size.height-2)
                let view = UIView(frame:rect)
                view.backgroundColor = STMConstants.STM_SUPERLIGHT_BLUE_COLOR
                view.tag = 1
                cell.contentView.addSubview(view)
                cell.contentView.sendSubviewToBack(view)
            }
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("debtDetailsCell",forIndexPath:indexPath)
        let debt = self.resultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.attributedText = self.textLabelForDebt(debt as! STMDebt, withFont:cell.textLabel!.font)
        cell.detailTextLabel!.attributedText = self.detailTextLabelForDebt(debt as! STMDebt, withFont:cell.detailTextLabel!.font)
        cell.selectionStyle = .None
        self.addLongPressToCell(cell)
        cell.textLabel?.numberOfLines = 2
//        cell.textLabel?.lineBreakMode = .ByWordWrapping
//        cell.detailTextLabel?.numberOfLines = 2
//        cell.detailTextLabel?.lineBreakMode = .ByWordWrapping
        
        let itemSize:CGSize = CGSizeMake(10, 10)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.mainScreen().scale)
        let imageRect : CGRect = CGRectMake(0, 0, itemSize.width, itemSize.height)
        cell.imageView!.image?.drawInRect(imageRect)
        cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.accessoryView = UIView(frame: CGRectMake(0, 0, 35, 35))
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 1000
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showDebtDetails", sender: nil)
    }
    
}

