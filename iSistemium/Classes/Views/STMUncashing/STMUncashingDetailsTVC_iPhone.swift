//
//  STMUncashingDetailsTVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 09/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMUncashingDetailsTVC_iPhone: STMUncashingDetailsTVC, UIPopoverPresentationControllerDelegate {
    
    // MARK: Superclass override
    
    override func showUncashingInfoPopover(){
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("uncashingInfoPopover") as! STMUncashingInfoVC
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(388,205)
        popover!.delegate = self
        popover!.sourceView = self.view
        let frame = (self.infoLabel!.valueForKey("view") as! UIView).frame
        popover!.sourceRect = frame
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func showAddButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed")
    }
    
    override func hideAddButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
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
        if (debt != nil){
            if cashingSumString != nil{
                backgroundColor = UIColor.clearColor()
                textColor = UIColor.blackColor()
                attributes = [
                    NSFontAttributeName: font,
                    NSBackgroundColorAttributeName: backgroundColor,
                    NSForegroundColorAttributeName: textColor
                ]
                text.appendAttributedString(NSAttributedString(string: cashingSumString! + " ", attributes: attributes as? [String : AnyObject]))
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
        }
        else{
            if (cashing.ndoc != nil) {
                text.appendAttributedString(NSAttributedString(string: cashing.ndoc,attributes: nil))
            } else {
                text.appendAttributedString(NSAttributedString(string: NSLocalizedString("NO DATA", comment: ""),attributes: nil))
            }
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
        if debt != nil{
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
        }
        return text
    }
    
    func messageTextLabelForDebt(cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let debt = cashing.debt
        if debt != nil{
            if cashing.date != nil {
                let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
                let cashingDate = dateFormatter().stringFromDate(cashing.date)
                backgroundColor = UIColor.clearColor()
                textColor = UIColor.blackColor()
                attributes = [
                    NSFontAttributeName: font,
                    NSBackgroundColorAttributeName: backgroundColor,
                    NSForegroundColorAttributeName: textColor
                ]
                let commentString = NSString(format:"%@ ", cashingDate)
                text.appendAttributedString(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
            }
            if cashing.commentText != nil {
                backgroundColor = UIColor.clearColor()
                textColor = UIColor.blackColor()
                attributes = [
                    NSFontAttributeName: font,
                    NSBackgroundColorAttributeName: backgroundColor,
                    NSForegroundColorAttributeName: textColor
                ]
                let commentString = NSString(format:"(%@) ", cashing.commentText)
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
        }
        return text
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(false, animated: true)
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 100
        tableView!.registerNib(UINib(nibName: "STMCustom6TVCell", bundle: nil), forCellReuseIdentifier: "STMCustom6TVCell")
    }
}
