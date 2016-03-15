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
    
    private var doneButton:STMBarButtonItem?
    
    private var cancelButton:STMBarButtonItem?
    
    private lazy var addDebt:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target:self, action:"addDebtButtonPressed:")
    
    private let dateButton = UIButton(type: .System)
    
    private func removeSwipeGesture(){
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.scrollEnabled = false
            }
        }
    }
    
    // MARK: STMDatePickerParent
    
    var selectedDate: NSDate?{
        didSet{
            STMCashingProcessController.sharedInstance().selectedDate = selectedDate
            let dateFormatter = STMFunctions.dateLongNoTimeFormatter
            self.dateButton.setTitle(dateFormatter().stringFromDate(selectedDate!),forState:.Normal)
            dateButton.sizeToFit()
        }
    }
    
    // MARK: Override superclass
    
    override func cashingProcessStart() {
        self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
        self.navigationItem.titleView = dateButton
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        selectedDate = NSDate()
        updateCashingLabel()
    }
    
    override func cashingProcessDone() {
        super.cashingProcessDone()
        self.navigationItem.titleView? = self.segmentedControl!
        self.navigationItem.setLeftBarButtonItem(self.navigationItem.backBarButtonItem, animated: false)
        self.buttonsForVC(self)
    }
    
    override func addDebtButtonPressed(sender:AnyObject){
        let content = self.storyboard!.instantiateViewControllerWithIdentifier("addDebtVC") as! STMAddDebtVC_iPhone
        content.parentVC = self
        let nav = UINavigationController(rootViewController: content)
        nav.modalPresentationStyle = .FullScreen
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
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
    
    // MARK: Toolbar
    
    private enum Toolbar{
        case Default
        case SetCashing
        case CashingSum
        case LimitedSum
        
        mutating func reset(){
            switch self{
            case .SetCashing:
                self = .SetCashing
            case .CashingSum:
                self = .CashingSum
            case .LimitedSum:
                self = .LimitedSum
            case .Default:
                self = .Default
            }
        }
    }
    
    private var toolbar:Toolbar = .Default{
        didSet{
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let summLabel = UILabel()
            switch toolbar{
            case .SetCashing:
                let setCahshingSumButton:UIBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: "setCashingSum")
                if let limit = STMCashingProcessController.sharedInstance().cashingSummLimit{
                    let numberFormatter = STMFunctions.currencyFormatter
                    setCahshingSumButton.title = NSLocalizedString("CASHING SUMM", comment: "") + ":"
                    summLabel.text = numberFormatter().stringFromNumber(limit)!
                }else{
                    setCahshingSumButton.title = NSLocalizedString("CASHING SUMM", comment: "")
                }
                summLabel.sizeToFit()
                self.setToolbarItems([flexibleSpace,setCahshingSumButton, UIBarButtonItem(customView: summLabel),flexibleSpace], animated: true)
                if setCahshingSumButton.valueForKey("view") != nil && summLabel.frame.size.width>UIScreen.mainScreen().bounds.width - (setCahshingSumButton.valueForKey("view")  as! UIView).frame.width - 15{
                    summLabel.frame.size.width = UIScreen.mainScreen().bounds.width - (setCahshingSumButton.valueForKey("view") as! UIView).frame.width - 15
                    summLabel.numberOfLines = 2
                    summLabel.lineBreakMode = .ByWordWrapping
                    summLabel.textAlignment = .Center
                    summLabel.sizeToFit()
                }
            case .CashingSum:
                let summ = STMCashingProcessController.sharedInstance().debtsSumm()
                let numberFormatter = STMFunctions.currencyFormatter
                let sumString = numberFormatter().stringFromNumber(summ)
                summLabel.text = NSLocalizedString("PICKED",comment: "") + " " + sumString!
                summLabel.sizeToFit()
                self.setToolbarItems([flexibleSpace,UIBarButtonItem(customView: summLabel),flexibleSpace],animated: true)
                if summLabel.frame.size.width>UIScreen.mainScreen().bounds.width - 15{
                    summLabel.frame.size.width = UIScreen.mainScreen().bounds.width - 15
                    summLabel.numberOfLines = 2
                    summLabel.lineBreakMode = .ByWordWrapping
                    summLabel.textAlignment = .Center
                    summLabel.sizeToFit()
                }
            case .LimitedSum:
                let fixedSpace = UIBarButtonItem(barButtonSystemItem: .FixedSpace , target: nil, action: nil)
                fixedSpace.width = -5
                let setCahshingSumButton:UIBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: "setCashingSum")
                let summ = STMCashingProcessController.sharedInstance().debtsSumm()
                let limit = STMCashingProcessController.sharedInstance().cashingSummLimit
                let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter()
                let sumString = numberFormatter.stringFromNumber(summ)!
                setCahshingSumButton.title = numberFormatter.stringFromNumber(limit)
                summLabel.text = String(format: NSLocalizedString("RECEIVE2",comment: ""), arguments: [sumString])
                summLabel.sizeToFit()
                self.setToolbarItems([flexibleSpace,UIBarButtonItem(customView: summLabel),fixedSpace,setCahshingSumButton,flexibleSpace],animated: true)
            case .Default:
                self.setToolbarItems([flexibleSpace,self.cashingButton,flexibleSpace], animated: true)
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
        let number = numberFormatter().numberFromString(textField.text!)
        textField.text = numberFormatter().stringFromNumber(number!)
        if number != nil && number!.doubleValue>0{
            STMCashingProcessController.sharedInstance().cashingSummLimit = NSDecimalNumber(decimal: number!.decimalValue)
        }
        updateCashingLabel()
        return true
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
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: Selectors
    
    func changeDate(){
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("datePickerVC") as! STMDatePickerVC
        popoverContent.parentVC = self
        popoverContent.selectedDate = STMCashingProcessController.sharedInstance().selectedDate
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.navigationBar.hidden = true
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
    
    func setCashingSum(){
        var cashingSum: UITextField?
        let alertController = UIAlertController(title: NSLocalizedString("CASHING SUMM", comment: ""), message: nil, preferredStyle: .Alert)
        let done = UIAlertAction(title: NSLocalizedString("DONE", comment: ""), style: .Default){ (action) -> Void in
            let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
            let number = numberFormatter().numberFromString(alertController.textFields![0].text!)
            if number != nil{
                STMCashingProcessController.sharedInstance().cashingSummLimit = NSDecimalNumber(decimal: number!.decimalValue)
            }
            if number == 0 || number == nil {
                STMCashingProcessController.sharedInstance().cashingSummLimit = nil
            }
            self.updateCashingLabel()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .Cancel, handler: nil)
        alertController.addAction(done)
        alertController.addAction(cancel)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
            var number = ""
            if STMCashingProcessController.sharedInstance().cashingSummLimit != nil{
                number = numberFormatter().stringFromNumber(STMCashingProcessController.sharedInstance().cashingSummLimit)!
            }
            cashingSum = textField
            cashingSum?.placeholder = NSLocalizedString("CASHING SUMM PLACEHOLDER", comment: "")
            cashingSum?.delegate = self
            cashingSum?.text = number
            cashingSum?.clearButtonMode = .Always
        }
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateCashingLabel() {
        if STMCashingProcessController.sharedInstance().debtsArray.count == 0{
            toolbar = .SetCashing
        }else if STMCashingProcessController.sharedInstance().cashingSummLimit == nil{
            toolbar = .CashingSum
        }
        else{
            toolbar = .LimitedSum
        }
    }
    
    // MARK: Observers
    
    override func addObservers(){
        super.addObservers()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateCashingLabel",
            name: "debtAdded",
            object: STMCashingProcessController.sharedInstance())
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateCashingLabel",
            name: "debtRemoved",
            object: STMCashingProcessController.sharedInstance())
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        removeSwipeGesture()
        doneButton = STMBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .Done, target: self, action: "cashingButtonPressed")
        cancelButton = STMBarButtonItem(title: NSLocalizedString("CANCEL", comment: ""), style: .Plain, target:STMCashingProcessController.sharedInstance(), action:"cancelCashingProcess")
        dateButton.addTarget(self, action: "changeDate", forControlEvents: .TouchUpInside)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        toolbar.reset()
    }
    
}
