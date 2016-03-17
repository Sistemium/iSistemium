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
    
    override var uncashing:STMUncashing?{
        didSet{
            if uncashing == nil{
                toolbar = .total
            }
        }
    }
    
    override func showUncashingInfoPopover(){
        let content = self.storyboard!.instantiateViewControllerWithIdentifier("uncashingInfoPopover") as! STMUncashingInfoVC
        content.uncashing = self.uncashing
        content.modalPresentationStyle = .Popover
        let popover = content.popoverPresentationController
        content.preferredContentSize = CGSizeMake(388,205)
        popover!.delegate = self
        popover!.sourceView = self.navigationController?.toolbar
        let frame = (self.infoLabel!.valueForKey("view") as! UIView).frame
        popover!.sourceRect = frame
        self.presentViewController(content, animated: true, completion: nil)
    }
    
    override func showAddButton() {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed"), animated: true)
    }
    
    override func hideAddButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    override func uncashingProcessStart() {
        self.tableView.setEditing(true, animated: true)
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        for cashing in self.resultsController.fetchedObjects! {
            let indexPath = self.resultsController.indexPathForObject(cashing)
            if indexPath != nil {
                self.tableView(self.tableView, willSelectRowAtIndexPath:indexPath!)
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        }
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelButtonPressed"), animated: true)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: NSLocalizedString("CONFIRM", comment: ""), style: .Plain, target: self, action: "confirmButtonPressed"), animated: true)
        self.navigationItem.titleView = UIView()
        toolbar = .sum
    }
    
    override func uncashingProcessDone(){
        self.tableView.allowsSelectionDuringEditing = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.setEditing(false, animated:true)
        self.uncashingProcessButton.title = NSLocalizedString("HAND OVER BUTTON",comment: "")
        self.setInfoLabelTitle()
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.navigationItem.titleView = nil
        toolbar = .total
        showAddButton()
    }
    
    // MARK: Toolbar
    private enum Toolbar{
        case total
        case sum
        
        mutating func reset(){
            switch self{
            case .total:
                self = .total
            case .sum:
                self = .sum
            }
        }
    }
    
    private var toolbar:Toolbar? {
        didSet{
            if toolbar != nil{
                switch toolbar!{
                case .total:
                    setInfoLabelTitle()
                    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                    self.view.layoutIfNeeded()
                    setToolbarItems([self.infoLabel!,flexibleSpace,self.uncashingProcessButton], animated: true)
                case .sum:
                    let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter()
                    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
                    var cashingSum = NSDecimalNumber.zero()
                    for cashing in self.resultsController.fetchedObjects! {
                        cashingSum = cashingSum.decimalNumberByAdding(cashing.summ)
                    }
                    var uncashingSum = NSDecimalNumber.zero()
                    for cashing in STMUncashingProcessController.sharedInstance().cashingDictionary.allValues {
                        uncashingSum = uncashingSum.decimalNumberByAdding(cashing.summ)
                    }
                    infoLabel?.title = NSLocalizedString("SUM", comment: "") + numberFormatter.stringFromNumber(uncashingSum)! + " " + NSLocalizedString("FROM", comment: "") + " " + numberFormatter.stringFromNumber(cashingSum)!
                    setToolbarItems([flexibleSpace,self.infoLabel!,flexibleSpace], animated: true)
                }
            }
        }
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: table view data
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let rez = super.numberOfSectionsInTableView(tableView)
        if rez == 0 {
            uncashingProcessButton.enabled = false
        }else{
            uncashingProcessButton.enabled = true
        }
        return rez
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("STMCustom6TVCell",forIndexPath:indexPath) as! STMCustom6TVCell
        cell.heightLimiter = 44
        cell.editingAccessoryType = .Checkmark
        let cashing = self.resultsController.objectAtIndexPath(indexPath) as! STMCashing
        cell.titleLabel?.attributedText = self.textLabelForDebt(cashing, withFont:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .None
        cell.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.detailLabel?.adjustsFontSizeToFitWidth = true
        
        if STMUncashingProcessController.sharedInstance().hasCashingWithXid(cashing.xid){
            
            cell.tintColor = STMSwiftConstants.ACTIVE_BLUE_COLOR
            
        } else {
            
            cell.tintColor = STMSwiftConstants.STM_LIGHT_LIGHT_GREY_COLOR
            
        }
        
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
        if uncashing != nil{
            textColor = UIColor.darkGrayColor()
        }else{
            textColor = UIColor.blackColor()
        }
        backgroundColor = UIColor.clearColor()
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if cashingSumString != nil{
            text.appendAttributedString(NSAttributedString(string: cashingSumString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if (debt != nil){
            if debt.ndoc != nil{
                text.appendAttributedString(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + debt.ndoc ,attributes:attributes as? [String : AnyObject]))
            }
        }
        else{
            if (cashing.ndoc != nil) {
                text.appendAttributedString(NSAttributedString(string:NSLocalizedString("FOR", comment: "") + " " + cashing.ndoc,attributes: attributes as? [String : AnyObject]))
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
        if uncashing != nil{
            textColor = UIColor.darkGrayColor()
        }else{
            textColor = UIColor.blackColor()
        }
        backgroundColor = UIColor.clearColor()
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if debt != nil{
            if debt.summOrigin != nil {
                let debtSumOriginString = numberFormatter().stringFromNumber(debt.summOrigin)
                text.appendAttributedString(NSAttributedString(string: NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumOriginString! + " ", attributes: attributes as? [String : AnyObject]))
            }
            if debt.date != nil {
                let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
                let debtDate = dateFormatter().stringFromDate(debt.date)
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
        if uncashing != nil{
            textColor = UIColor.darkGrayColor()
        }else{
            textColor = UIColor.blackColor()
        }
        backgroundColor = UIColor.clearColor()
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if cashing.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let cashingDate = dateFormatter().stringFromDate(cashing.date)
            let commentString = NSString(format:"%@ ", cashingDate)
            text.appendAttributedString(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        if cashing.commentText != nil {
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
    
    // MARK: Selectors
    
    func addButtonPressed() {
        let alert = UIAlertController(title: NSLocalizedString("ADD SUM", comment: ""), message: nil, preferredStyle: .ActionSheet)
        let etc = UIAlertAction(title: NSLocalizedString("ETC", comment: ""), style: .Default){
            (action) -> Void in
            let content = self.storyboard!.instantiateViewControllerWithIdentifier("addEtceteraVC") as! STMAddEtceteraVC
            content.cashingType = .Etcetera
            let nav = UINavigationController(rootViewController: content)
            nav.modalPresentationStyle = .FullScreen
            self.presentViewController(nav, animated: true, completion: nil)
        }
        let deduction = UIAlertAction(title: NSLocalizedString("DEDUCTION", comment: ""), style: .Default){
            (action) -> Void in
            let content = self.storyboard!.instantiateViewControllerWithIdentifier("addEtceteraVC") as! STMAddEtceteraVC
            content.cashingType = .Deduction
            let nav = UINavigationController(rootViewController: content)
            nav.modalPresentationStyle = .FullScreen
            self.presentViewController(nav, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .Cancel, handler: nil)
        alert.addAction(etc)
        alert.addAction(deduction)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func cancelButtonPressed(){
        STMUncashingProcessController.sharedInstance().cancelProcess()
        uncashingProcessDone()
    }
    
    func resetToolbar(){
        toolbar?.reset()
    }
    
    func confirmButtonPressed(){
        if STMUncashingProcessController.sharedInstance().isCashingSelected(){
            let content = self.storyboard!.instantiateViewControllerWithIdentifier("uncashingHandOverVC")
            self.navigationController?.showViewController(content, sender: self)
        }
    }
    
    // MARK: View lifecycle
    
    override func addObservers(){
        super.addObservers()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetToolbar", name: "cashingDictionaryChanged", object: STMUncashingProcessController.sharedInstance())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 100
        tableView!.registerNib(UINib(nibName: "STMCustom6TVCell", bundle: nil), forCellReuseIdentifier: "STMCustom6TVCell")
        let backItem = UIBarButtonItem(title: NSLocalizedString("BACK", comment: ""), style: .Plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setToolbarHidden(false, animated: true)
    }
}
