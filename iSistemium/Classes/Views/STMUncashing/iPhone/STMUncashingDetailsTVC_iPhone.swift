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
        let content = self.storyboard!.instantiateViewController(withIdentifier: "uncashingInfoPopover") as! STMUncashingInfoVC
        content.uncashing = self.uncashing
        content.modalPresentationStyle = .popover
        let popover = content.popoverPresentationController
        content.preferredContentSize = CGSize(width: 388,height: 205)
        popover!.delegate = self
        popover!.sourceView = self.navigationController?.toolbar
        let frame = (self.infoLabel!.value(forKey: "view") as! UIView).frame
        popover!.sourceRect = frame
        self.present(content, animated: true, completion: nil)
    }
    
    override func showAddButton() {
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(STMUncashingDetailsTVC_iPhone.addButtonPressed)), animated: true)
    }
    
    override func hideAddButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    override func uncashingProcessStart() {
        self.tableView.setEditing(true, animated: true)
        self.tableView.allowsSelectionDuringEditing = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        for cashing in self.resultsController.fetchedObjects! {
            let indexPath = self.resultsController.indexPath(forObject: cashing)
            if indexPath != nil {
                self.tableView(self.tableView, willSelectRowAt:indexPath!)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
        }
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(STMUncashingDetailsTVC_iPhone.cancelButtonPressed)), animated: true)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: NSLocalizedString("CONFIRM", comment: ""), style: .plain, target: self, action: #selector(STMUncashingDetailsTVC_iPhone.confirmButtonPressed)), animated: true)
        self.navigationItem.titleView = UIView()
        toolbar = .sum
    }
    
    override func uncashingProcessDone(){
        self.tableView.allowsSelectionDuringEditing = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.setEditing(false, animated:true)
        self.uncashingProcessButton.title = NSLocalizedString("HAND OVER BUTTON",comment: "")
        self.setInfoLabelTitle()
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.navigationItem.titleView = nil
        toolbar = .total
        showAddButton()
    }
    
    // MARK: Toolbar
    fileprivate enum Toolbar{
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
    
    fileprivate var toolbar:Toolbar? {
        didSet{
            if toolbar != nil{
                switch toolbar!{
                case .total:
                    setInfoLabelTitle()
                    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    self.view.layoutIfNeeded()
                    setToolbarItems([self.infoLabel!,flexibleSpace,self.uncashingProcessButton], animated: true)
                case .sum:
                    let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter()
                    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                    var cashingSum = NSDecimalNumber.zero
                    for cashing in self.resultsController.fetchedObjects! {
                        cashingSum = cashingSum.adding((cashing as! STMCashing).summ ?? 0)
                    }
                    var uncashingSum = NSDecimalNumber.zero
                    for cashing in STMUncashingProcessController.sharedInstance().cashingDictionary.allValues {
                        uncashingSum = uncashingSum.adding((cashing as AnyObject).summ ?? 0)
                    }
                    infoLabel?.title = NSLocalizedString("SUM", comment: "") + numberFormatter.string(from: uncashingSum)! + " " + NSLocalizedString("FROM", comment: "") + " " + numberFormatter.string(from: cashingSum)!
                    setToolbarItems([flexibleSpace,self.infoLabel!,flexibleSpace], animated: true)
                }
            }
        }
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for PC: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let rez = super.numberOfSections(in: tableView)
        if rez == 0 {
            uncashingProcessButton.isEnabled = false
        }else{
            uncashingProcessButton.isEnabled = true
        }
        return rez
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STMCustom6TVCell",for:indexPath) as! STMCustom6TVCell
        cell.heightLimiter = 44
        cell.editingAccessoryType = .checkmark
        let cashing = self.resultsController.object(at: indexPath) as! STMCashing
        cell.titleLabel?.attributedText = self.textLabelForDebt(cashing, withFont:cell.titleLabel!.font)
        cell.detailLabel?.attributedText = self.detailTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.messageLabel?.attributedText = self.messageTextLabelForDebt(cashing, withFont:cell.detailLabel!.font)
        cell.selectionStyle = .none
        cell.titleLabel?.adjustsFontSizeToFitWidth = true
        cell.detailLabel?.adjustsFontSizeToFitWidth = true
        
        if STMUncashingProcessController.sharedInstance().hasCashing(withXid: cashing.xid){
            
            cell.tintColor = STMSwiftConstants.ACTIVE_BLUE_COLOR
            
        } else {
            
            cell.tintColor = STMSwiftConstants.STM_LIGHT_LIGHT_GREY_COLOR
            
        }
        
        return cell
    }
    
    func textLabelForDebt(_ cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let numberFormatter = STMFunctions.currencyFormatter
        let debt = cashing.debt
        if uncashing != nil{
            textColor = UIColor.darkGray
        }else{
            textColor = UIColor.black
        }
        backgroundColor = UIColor.clear
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if let summ = cashing.summ{
            let cashingSumString = numberFormatter().string(from: summ)
            text.append(NSAttributedString(string: cashingSumString! + " ", attributes: attributes as? [String : AnyObject]))
        }
        if (debt != nil){
            if debt!.ndoc != nil{
                text.append(NSAttributedString(string: NSLocalizedString("FOR", comment: "") + " " + debt!.ndoc! ,attributes:attributes as? [String : AnyObject]))
            }
        }
        else{
            if (cashing.ndoc != nil) {
                text.append(NSAttributedString(string:NSLocalizedString("FOR", comment: "") + " " + cashing.ndoc!,attributes: attributes as? [String : AnyObject]))
            }
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
        if uncashing != nil{
            textColor = UIColor.darkGray
        }else{
            textColor = UIColor.black
        }
        backgroundColor = UIColor.clear
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if debt != nil{
            if debt!.summOrigin != nil {
                let debtSumOriginString = numberFormatter().string(from: debt!.summOrigin!)
                text.append(NSAttributedString(string: NSLocalizedString("BY SUMM", comment: "").uppercaseFirst + " " + debtSumOriginString! + " ", attributes: attributes as? [String : AnyObject]))
            }
            if debt!.date != nil {
                let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
                let debtDate = dateFormatter().string(from: debt!.date!)
                text.append(NSAttributedString(string: NSLocalizedString("OF", comment: "") + " " + debtDate, attributes: attributes as? [String : AnyObject]))
            }
        }
        return text
    }
    
    func messageTextLabelForDebt(_ cashing: STMCashing, withFont font: UIFont!) -> NSMutableAttributedString! {
        var backgroundColor :UIColor
        var textColor :UIColor
        var attributes: NSDictionary
        let text = NSMutableAttributedString()
        let debt = cashing.debt
        if uncashing != nil{
            textColor = UIColor.darkGray
        }else{
            textColor = UIColor.black
        }
        backgroundColor = UIColor.clear
        attributes = [
            NSFontAttributeName: font,
            NSBackgroundColorAttributeName: backgroundColor,
            NSForegroundColorAttributeName: textColor
        ]
        if cashing.date != nil {
            let dateFormatter = STMFunctions.dateMediumNoTimeFormatter
            let cashingDate = dateFormatter().string(from: cashing.date!)
            let commentString = NSString(format:"%@ ", cashingDate)
            text.append(NSAttributedString(string: commentString as String, attributes:attributes as? [String : AnyObject]))
        }
        if cashing.commentText != nil {
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
    
    // MARK: Selectors
    
    func addButtonPressed() {
        let alert = UIAlertController(title: NSLocalizedString("ADD SUM", comment: ""), message: nil, preferredStyle: .actionSheet)
        let etc = UIAlertAction(title: NSLocalizedString("ETC", comment: ""), style: .default){
            (action) -> Void in
            let content = self.storyboard!.instantiateViewController(withIdentifier: "addEtceteraVC") as! STMAddEtceteraVC
            content.cashingType = .etcetera
            let nav = UINavigationController(rootViewController: content)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        let deduction = UIAlertAction(title: NSLocalizedString("DEDUCTION", comment: ""), style: .default){
            (action) -> Void in
            let content = self.storyboard!.instantiateViewController(withIdentifier: "addEtceteraVC") as! STMAddEtceteraVC
            content.cashingType = .deduction
            let nav = UINavigationController(rootViewController: content)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil)
        alert.addAction(etc)
        alert.addAction(deduction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
            let content = self.storyboard!.instantiateViewController(withIdentifier: "uncashingHandOverVC")
            self.navigationController?.show(content, sender: self)
        }
    }
    
    // MARK: View lifecycle
    
    override func addObservers(){
        super.addObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(STMUncashingDetailsTVC_iPhone.resetToolbar), name: NSNotification.Name(rawValue: "cashingDictionaryChanged"), object: STMUncashingProcessController.sharedInstance())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.estimatedRowHeight = 100
        tableView!.register(UINib(nibName: "STMCustom6TVCell", bundle: nil), forCellReuseIdentifier: "STMCustom6TVCell")
        let backItem = UIBarButtonItem(title: NSLocalizedString("BACK", comment: ""), style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setToolbarHidden(false, animated: true)
    }
}
