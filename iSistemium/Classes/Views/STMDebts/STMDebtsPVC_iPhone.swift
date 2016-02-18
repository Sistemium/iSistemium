//
//  STMDebtsDetailsPVC_Iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 26/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMDebtsPVC_iPhone: STMDebtsDetailsPVC, UIPopoverPresentationControllerDelegate, STMDatePickerParent, UITextFieldDelegate{
    
    enum Toolbar{
        case Default
        case SetCashing
        case CashingSum
    }
    
    var toolbar:Toolbar = .Default{
        didSet{
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let summLabel = UILabel()
            switch toolbar{
            case .SetCashing:
                self.setToolbarItems([flexibleSpace,self.setCahshingSumButton, UIBarButtonItem(customView: summLabel),flexibleSpace], animated: false)
                if let limit = STMCashingProcessController.sharedInstance().cashingSummLimit{
                    let numberFormatter = STMFunctions.currencyFormatter
                    setCahshingSumButton.title = NSLocalizedString("CASHING SUMM", comment: "") + ":"
                    summLabel.text = numberFormatter().stringFromNumber(limit)!
                }else{
                    setCahshingSumButton.title = NSLocalizedString("CASHING SUMM", comment: "") + ":"
                    summLabel.text = NSLocalizedString("NO", comment: "")
                }
                summLabel.sizeToFit()
                if summLabel.frame.size.width>UIScreen.mainScreen().bounds.width - (self.setCahshingSumButton.valueForKey("view") as! UIView).frame.width - 15{
                    summLabel.frame.size.width = UIScreen.mainScreen().bounds.width - (self.setCahshingSumButton.valueForKey("view") as! UIView).frame.width - 15
//                    summLabel.adjustsFontSizeToFitWidth = true
//                    summLabel.minimumScaleFactor = 0.8
                    summLabel.numberOfLines = 2
                    summLabel.lineBreakMode = .ByWordWrapping
                    summLabel.textAlignment = .Center
                    summLabel.sizeToFit()
                }
            case .CashingSum:
                self.setToolbarItems([flexibleSpace,UIBarButtonItem(customView: summLabel),flexibleSpace],animated: false)
                let summ = STMCashingProcessController.sharedInstance().debtsSumm()
                let numberFormatter = STMFunctions.currencyFormatter
                let sumString = numberFormatter().stringFromNumber(summ)
                summLabel.text = NSLocalizedString("PICKED",comment: "") + " " + sumString!
                summLabel.sizeToFit()
                if summLabel.frame.size.width>UIScreen.mainScreen().bounds.width - 15{
                    summLabel.frame.size.width = UIScreen.mainScreen().bounds.width - 15
//                    summLabel.adjustsFontSizeToFitWidth = true
//                    summLabel.minimumScaleFactor = 0.8
                    summLabel.numberOfLines = 2
                    summLabel.lineBreakMode = .ByWordWrapping
                    summLabel.textAlignment = .Center
                    summLabel.sizeToFit()
                }
            case .Default:
                self.setToolbarItems([flexibleSpace,self.cashingButton,flexibleSpace], animated: false)
            }
        }
    }
    
    var selectedDate: NSDate?{
        didSet{
            STMCashingProcessController.sharedInstance().selectedDate = selectedDate
            let dateFormatter = STMFunctions.dateLongNoTimeFormatter
            self.dateButton.setTitle(dateFormatter().stringFromDate(selectedDate!),forState:.Normal)
            dateButton.sizeToFit()
        }
    }
    
    private var doneButton:STMBarButtonItem?
    
    private var cancelButton:STMBarButtonItem?
    
    private let setCahshingSumLabel = UILabel()
    
    private lazy var setCahshingSumButton:UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CASHING SUMM", comment: "") + ": " + NSLocalizedString("NO", comment: ""), style: .Plain, target: self, action: "setCashingSum")
    
    private lazy var addDebt:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target:self, action:"addDebtButtonPressed:")
    
    let dateButton = UIButton(type: .System)
    
    override func buttonsForVC(vc:UIViewController){
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.addDebtButton = addDebt
        self.navigationItem.rightBarButtonItem = self.addDebtButton
        if vc.isKindOfClass(STMOutletCashingVC){
            self.navigationItem.rightBarButtonItem = nil
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        self.toolbar = .Default
    }
    
    override func cashingButtonPressed() {
        super.cashingButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        removeSwipeGesture()
        doneButton = STMBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .Done, target: self, action: "cashingButtonPressed")
        cancelButton = STMBarButtonItem(title: NSLocalizedString("CANCEL", comment: ""), style: .Plain, target:STMCashingProcessController.sharedInstance(), action:"cancelCashingProcess")
        cancelButton!.tintColor = .redColor()
        dateButton.addTarget(self, action: "changeDate", forControlEvents: .TouchUpInside)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func removeSwipeGesture(){
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.scrollEnabled = false
            }
        }
    }
    
    override func addDebtButtonPressed(sender:AnyObject){
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("addDebtVC") as! STMAddDebtVC_iPhone
        popoverContent.parentVC = self
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(388,205)
        popover?.delegate = self
        popover?.sourceView = self.view
        var frame = (self.addDebtButton.valueForKey("view") as! UIView).frame
        frame.origin.y -= 60
        popover?.sourceRect = frame
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func cashingProcessStart() {
        super.cashingProcessStart()
        self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
        self.navigationItem.titleView = dateButton
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        selectedDate = NSDate()
        showCashingLabel()
    }
    
    func changeDate(){
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("datePickerVC") as! STMDatePickerVC
        popoverContent.parentVC = self
        popoverContent.selectedDate = STMCashingProcessController.sharedInstance().selectedDate
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .Popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(388,205)
        popover?.delegate = self
        popover?.sourceView = self.view
        var frame = dateButton.frame
        frame.origin.y -= 60
        popover?.sourceRect = frame
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func cashingProcessDone() {
        super.cashingProcessDone()
        self.navigationItem.titleView? = self.segmentedControl!
        self.navigationItem.setLeftBarButtonItem(self.navigationItem.backBarButtonItem, animated: false)
        self.buttonsForVC(self)
    }
    
    func showCashingLabel() {
        if STMCashingProcessController.sharedInstance().debtsArray.count == 0{
            toolbar = .SetCashing
        }else{
            toolbar = .CashingSum
        }
    }
    
    override func addObservers(){
        super.addObservers()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "showCashingLabel",
            name: "debtAdded",
            object: STMCashingProcessController.sharedInstance())
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "showCashingLabel",
            name: "debtRemoved",
            object: STMCashingProcessController.sharedInstance())
    }
    
    func setCashingSum(){
        var cashingSum: UITextField?
        let alertController = UIAlertController(title: NSLocalizedString("CASHING SUMM", comment: ""), message: nil, preferredStyle: .Alert)
        let done = UIAlertAction(title: NSLocalizedString("DONE", comment: ""), style: .Default, handler: { (action) -> Void in
            let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
            let number = numberFormatter().numberFromString(alertController.textFields![0].text!)
            if number != nil{
                STMCashingProcessController.sharedInstance().cashingSummLimit = NSDecimalNumber(decimal: number!.decimalValue)
            }
            if number == 0 {
                STMCashingProcessController.sharedInstance().cashingSummLimit = nil
            }
            self.showCashingLabel()
        })
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(done)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
            let number = numberFormatter().stringFromNumber(STMCashingProcessController.sharedInstance().cashingSummLimit ?? 0)
            cashingSum = textField
            cashingSum?.placeholder = NSLocalizedString("CASHING SUMM PLACEHOLDER", comment: "")
            cashingSum?.delegate = self
            cashingSum?.text = number
            cashingSum?.clearButtonMode = .Always
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let numberFormatter = STMFunctions.decimalMaxTwoDigitFormatter()
        let text = textField.text!.mutableCopy()
        text.replaceCharactersInRange(range, withString:string)
        let textParts = text.componentsSeparatedByString(numberFormatter.decimalSeparator)
        let decimalPart:String? = textParts.count == 2 ? textParts[1] : nil
        if decimalPart?.characters.count == 3 && string != "" {
            return false
        } else {
            text.replaceOccurrencesOfString(numberFormatter.groupingSeparator, withString:"", options: .CaseInsensitiveSearch, range:NSMakeRange(0, text.length))
            self.fillTextField(textField, withText: text as! String)
            return false
        }
    }
    
    func fillTextField(textField:UITextField, withText text:String) {
        let numberFormatter = STMFunctions.decimalMaxTwoDigitFormatter()
        let number = numberFormatter.numberFromString(text)
        if number == nil {
            if text == "" {
                textField.text = text
            }
        } else {
            if number!.doubleValue == 0 {
                textField.text = text
            } else {
                var finalString = numberFormatter.stringFromNumber(number!)
                var appendingString:String? = nil
                var suffix:String? = nil
                for (var i = 0; i <= 2; i++) {
                    suffix = numberFormatter.decimalSeparator
                    for (var j = 0; j < i; j++) {
                        suffix = suffix!.stringByAppendingString("0")
                    }
                    appendingString = text.hasSuffix(suffix!) ? suffix : appendingString
                }
                finalString = appendingString != nil ? finalString!.stringByAppendingString(appendingString!) : finalString
                textField.text = finalString
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
        let number = numberFormatter().numberFromString(textField.text!)
        textField.text = numberFormatter().stringFromNumber(number!)
        if number != nil && number!.doubleValue>0{
            STMCashingProcessController.sharedInstance().cashingSummLimit = NSDecimalNumber(decimal: number!.decimalValue)
        }
        showCashingLabel()
        return true
    }
}
