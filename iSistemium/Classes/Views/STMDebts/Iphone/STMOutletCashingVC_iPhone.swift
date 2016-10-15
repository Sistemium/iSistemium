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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STMCustom6TVCell",for:indexPath) as! STMCustom6TVCell
        let cashing = self.resultsController.object(at: indexPath) as! STMCashing
        
        cell.titleLabel?.attributedText = self.textLabelForDebt(cashing, withFont:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .none
        cell.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.detailLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func textLabelForDebt(_ cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let cashingSumString = numberFormatter().string(from: cashing.summ!)
        let debt = cashing.debt
        backgroundColor = UIColor.clear
        textColor = UIColor.darkGray
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if cashingSumString != nil{
            text.append(NSAttributedString(string: cashingSumString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt?.ndoc != nil{
            text.append(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + debt!.ndoc! ,attributes:attributes as? [String : AnyObject]))
        }
        return text
    }
    
    func detailTextLabelForDebt(_ cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
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
            debtSumOriginString = numberFormatter().string(from: debt!.summOrigin!)
        }
        backgroundColor = UIColor.clear
        textColor = UIColor.darkGray
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if debtSumOriginString != nil{
            text.append(NSAttributedString(string: NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumOriginString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if debt?.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let debtDate = dateFormatter().string(from: debt!.date!)
            text.append(NSAttributedString(string: NSLocalizedString("OF", comment: "") + " " + debtDate, attributes: attributes as? [String : AnyObject]))
        }
        return text
    }
    
    func messageTextLabelForDebt(_ cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let debt = cashing.debt
        if cashing.commentText != nil {
            backgroundColor = UIColor.clear
            textColor = UIColor.darkGray
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let commentString = NSString(format:"(%@) ", cashing.commentText!)
            text.append(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        if debt?.responsibility != nil {
            backgroundColor = UIColor.gray
            textColor = UIColor.white
            attributes = [
                NSFontAttributeName: font,
                NSBackgroundColorAttributeName: backgroundColor,
                NSForegroundColorAttributeName: textColor
            ]
            let responsibilityString = NSString(format: "%@", debt!.responsibility!)
            text.append(NSAttributedString(string:responsibilityString as String, attributes:attributes as? [String : AnyObject]))
            text.append(NSAttributedString(string: " "))
        }
        return text
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 100
        tableView!.register(UINib(nibName: "STMCustom6TVCell", bundle: nil), forCellReuseIdentifier: "STMCustom6TVCell")
    }
}
