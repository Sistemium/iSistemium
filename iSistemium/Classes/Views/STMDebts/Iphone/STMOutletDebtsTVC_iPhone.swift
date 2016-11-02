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
    
    override func showLongPressActionSheet(from view:UIView) {
        if view.isKind(of: UITableViewCell.self) {
            let cell = view as! UITableViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            self.selectedDebt = self.resultsController.object(at: indexPath!) as! STMDebt
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: NSLocalizedString("CANCEL", comment: ""), destructiveButtonTitle: nil)
            actionSheet.addButton(withTitle: NSLocalizedString("COPY", comment: ""))
            if MFMailComposeViewController.canSendMail() {
            actionSheet.addButton(withTitle: NSLocalizedString("SEND EMAIL", comment: ""))
            }
            if MFMessageComposeViewController.canSendText() {
            actionSheet.addButton(withTitle: NSLocalizedString("SEND MESSAGE", comment: ""))
            }
            actionSheet.tag = 111
            actionSheet.show(from: cell.frame, in: self.tableView, animated: true)
        }
    }
    
    // MARK: Table view data
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rez = super.tableView(tableView, numberOfRowsInSection: section)
        if rez == 0 {
            self.parentVC?.cashingButton.isEnabled = false
        }else{
            self.parentVC?.cashingButton.isEnabled = true
        }
        return rez
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "debtDetailsCell",for:indexPath) as! STMThreeLinesAndCheckboxTVCell
        let debt = self.resultsController.object(at: indexPath)
        cell.titleLabel?.attributedText = self.textLabel(for: debt as! STMDebt, with:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabel(for: debt as! STMDebt, with:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(debt as! STMDebt, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .none
        self.addLongPress(to: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let customCell = cell as! STMThreeLinesAndCheckboxTVCell
        let debt = self.resultsController.object(at: indexPath) as! STMDebt
        customCell.contentView.viewWithTag(1)?.removeFromSuperview()
        customCell.tintColor = STMSwiftConstants.ACTIVE_BLUE_COLOR
        customCell.accessoryType = .none
        customCell.titleLabel!.backgroundColor = UIColor.clear
        customCell.detailLabel!.backgroundColor = UIColor.clear
        customCell.checkboxView.viewWithTag(444)?.removeFromSuperview()
        
        if STMCashingProcessController.sharedInstance().state == .running {
            
            var fillWidth: CGFloat = 0
            let debtsDictionary: NSDictionary = STMCashingProcessController.sharedInstance().debtsDictionary
            
            if debt.xid != nil && debtsDictionary.allKeys.contains(where: {$0 as? Data == debt.xid}) {
                
                let debtValues: NSArray = debtsDictionary[debt.xid!]! as! NSArray
                let cashingSum = debtValues[1]
                fillWidth = CGFloat((cashingSum as AnyObject).dividing(by: debt.calculatedSum ?? 0).doubleValue)
                
                let checkLabel = STMLabel(frame: customCell.checkboxView.bounds)
                checkLabel.adjustsFontSizeToFitWidth = true
                checkLabel.text = "✓"
                checkLabel.textColor = STMSwiftConstants.ACTIVE_BLUE_COLOR
                checkLabel.textAlignment = .left
                checkLabel.tag = 444
                customCell.checkboxView.addSubview(checkLabel)

                customCell.accessoryType = .detailButton

            } else {
                
                customCell.accessoryType = .none
                
            }
            
            if (fillWidth != 0) {
                fillWidth *= customCell.frame.size.width
                if (fillWidth < 10) {
                    fillWidth = 10
                }
                let rect = CGRect(x: 0, y: 1, width: fillWidth, height: customCell.frame.size.height-2)
                let view = UIView(frame:rect)
                view.backgroundColor = STMSwiftConstants.STM_SUPERLIGHT_BLUE_COLOR
                view.tag = 1
                customCell.contentView.addSubview(view)
                customCell.contentView.sendSubview(toBack: view)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "showDebtDetails", sender: resultsController.object(at: indexPath) as! STMDebt)
    }
    
    override func textLabel(for debt: STMDebt!, with font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let debtSumString = numberFormatter().string(from: debt.calculatedSum ?? 0)
        if debtSumString != nil{
            backgroundColor = UIColor.clear
            textColor = UIColor.black
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.append(NSAttributedString(string: debtSumString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if let ndoc = debt.ndoc{
            backgroundColor = UIColor.clear
            textColor = UIColor.black
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.append(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + ndoc ,attributes:attributes as? [String : AnyObject]))
        }
        return text
    }
    
    
    override func detailTextLabel(for debt: STMDebt!, with font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        if let summOrigin = debt.summOrigin {
            let debtSumOriginString = numberFormatter().string(from: summOrigin)
            backgroundColor = UIColor.clear
            textColor = UIColor.black
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.append(NSAttributedString(string: NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumOriginString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let debtDate = dateFormatter().string(from: debt.date!)
            backgroundColor = UIColor.clear
            textColor = UIColor.black
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            text.append(NSAttributedString(string: NSLocalizedString("OF", comment: "") + " " + debtDate, attributes: attributes as? [String : AnyObject]))
        }
        return text
    }
    
    func messageTextLabelForDebt(_ debt: STMDebt!, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        if debt.dateE != nil{
            backgroundColor = UIColor.clear
            textColor = UIColor.black
            var numberOfDays = STMFunctions.daysFromToday(to: debt.dateE!)
            var dueDate : NSString
            switch numberOfDays.int32Value{
            case 0:
                textColor = UIColor.purple
                dueDate = NSLocalizedString("TODAY", comment: "") as NSString
            case 1:
                dueDate = NSLocalizedString("TOMORROW", comment:"") as NSString
            case -1:
                textColor = UIColor.red
                dueDate = NSLocalizedString("YESTERDAY", comment: "") as NSString
            default:
                let pluralType = STMFunctions.pluralType(forCount: UInt(abs(numberOfDays.int32Value)))
                let dateIsInPast = numberOfDays.int32Value < 0
                if dateIsInPast {
                    let positiveNumberOfDays = -1 * numberOfDays.int32Value
                    numberOfDays = NSNumber(value: positiveNumberOfDays as Int32)
                }
                dueDate = NSString(format: "%@ %@", numberOfDays, NSLocalizedString(pluralType + "DAYS", comment: ""))
                if (dateIsInPast) {
                    textColor = UIColor.red
                    dueDate = NSString(format: "%@ %@", NSLocalizedString("AGO", comment: ""), dueDate)
                }
            }
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let dueDateHeader = NSString(format: "%@: ", NSLocalizedString("DUE DATE", comment:""))
            text.append(NSAttributedString(string: dueDateHeader as String,attributes:attributes as? [String : AnyObject]))
            text.append(NSAttributedString(string: dueDate as String + " ", attributes:attributes as? [String : AnyObject]))
        }
        if debt.commentText != nil {
            backgroundColor = UIColor.clear
            textColor = UIColor.black
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let commentString = NSString(format:"(%@) ", debt.commentText!)
            text.append(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        if debt.responsibility != nil {
            backgroundColor = UIColor.gray
            textColor = UIColor.white
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let responsibilityString = NSString(format: "%@", debt.responsibility!)
            text.append(NSAttributedString(string:responsibilityString as String, attributes:attributes as? [String : AnyObject]))
            text.append(NSAttributedString(string: " "))
        }
        return text
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showDebtDetails"{
            (segue.destination as! STMCashingControlsVC_iPhone).selectedDebt = sender as! STMDebt
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "STMThreeLinesAndCheckboxTVCell", bundle: nil), forCellReuseIdentifier: "debtDetailsCell")
    }
}

