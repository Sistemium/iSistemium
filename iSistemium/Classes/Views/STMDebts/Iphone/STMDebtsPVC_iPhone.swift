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
    
    fileprivate var doneButton:STMBarButtonItem?
    
    fileprivate var cancelButton:STMBarButtonItem?
    
    fileprivate lazy var addDebt:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target:self, action:#selector(STMDebtsDetailsPVC.addDebtButtonPressed(_:)))
    
    fileprivate let dateButton = UIButton(type: .system)
    
    fileprivate func removeSwipeGesture(){
        for view in self.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }
    
    // MARK: STMDatePickerParent
    
    var selectedDate: Date?{
        didSet{
            STMCashingProcessController.sharedInstance().selectedDate = selectedDate
            let dateFormatter = STMFunctions.dateLongNoTimeFormatter
            self.dateButton.setTitle(dateFormatter().string(from: selectedDate!),for:UIControlState())
            dateButton.sizeToFit()
        }
    }
    
    // MARK: Override superclass
    
    override func cashingProcessStart() {
        self.navigationItem.setRightBarButton(doneButton, animated: true)
        self.navigationItem.titleView = dateButton
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        selectedDate = Date()
        updateCashingLabel()
    }
    
    override func cashingProcessDone() {
        super.cashingProcessDone()
        let segment:UISegmentedControl?
        if self.segmentedControl == nil {
            segment = UISegmentedControl()
            self.segmentedControl = segment
            self.segmentedControl!.sizeToFit()
            setupSegmentedControl()
        }
        self.navigationItem.setLeftBarButton(self.navigationItem.backBarButtonItem, animated: true)
        self.buttons(forVC: self)
        self.navigationItem.titleView? = self.segmentedControl!
    }
    
    override func addDebtButtonPressed(_ sender: Any!) {
        let content = self.storyboard!.instantiateViewController(withIdentifier: "addDebtVC") as! STMAddDebtVC_iPhone
        content.parentVC = self
        let nav = UINavigationController(rootViewController: content)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    override func buttons(forVC vc:UIViewController){
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.addDebtButton = addDebt
        self.navigationItem.rightBarButtonItem = self.addDebtButton
        if vc.isKind(of: STMOutletCashingVC.self){
            self.navigationItem.rightBarButtonItem = nil
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
        self.toolbar = .default
    }
    
    // MARK: Toolbar
    
    fileprivate enum Toolbar{
        case `default`
        case setCashing
        case cashingSum
        case limitedSum
        
        mutating func reset(){
            switch self{
            case .setCashing:
                self = .setCashing
            case .cashingSum:
                self = .cashingSum
            case .limitedSum:
                self = .limitedSum
            case .default:
                self = .default
            }
        }
    }
    
    fileprivate var toolbar:Toolbar = .default{
        didSet{
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let summLabel = UILabel()
            switch toolbar{
            case .setCashing:
                let setCahshingSumButton:UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(STMDebtsPVC_iPhone.setCashingSum))
                if let limit = STMCashingProcessController.sharedInstance().cashingSummLimit{
                    let numberFormatter = STMFunctions.currencyFormatter
                    setCahshingSumButton.title = NSLocalizedString("CASHING SUMM", comment: "") + ":"
                    summLabel.text = numberFormatter().string(from: limit)!
                }else{
                    setCahshingSumButton.title = NSLocalizedString("CASHING SUMM", comment: "")
                }
                summLabel.sizeToFit()
                self.setToolbarItems([flexibleSpace,setCahshingSumButton, UIBarButtonItem(customView: summLabel),flexibleSpace], animated: true)
                if setCahshingSumButton.value(forKey: "view") != nil && summLabel.frame.size.width>UIScreen.main.bounds.width - (setCahshingSumButton.value(forKey: "view")  as! UIView).frame.width - 15{
                    summLabel.frame.size.width = UIScreen.main.bounds.width - (setCahshingSumButton.value(forKey: "view") as! UIView).frame.width - 15
                    summLabel.numberOfLines = 2
                    summLabel.lineBreakMode = .byWordWrapping
                    summLabel.textAlignment = .center
                    summLabel.sizeToFit()
                }
            case .cashingSum:
                let summ = STMCashingProcessController.sharedInstance().debtsSumm()
                let numberFormatter = STMFunctions.currencyFormatter
                let sumString = numberFormatter().string(from: summ!)
                summLabel.text = NSLocalizedString("PICKED",comment: "") + " " + sumString!
                summLabel.sizeToFit()
                self.setToolbarItems([flexibleSpace,UIBarButtonItem(customView: summLabel),flexibleSpace],animated: true)
                if summLabel.frame.size.width>UIScreen.main.bounds.width - 15{
                    summLabel.frame.size.width = UIScreen.main.bounds.width - 15
                    summLabel.numberOfLines = 2
                    summLabel.lineBreakMode = .byWordWrapping
                    summLabel.textAlignment = .center
                    summLabel.sizeToFit()
                }
            case .limitedSum:
                let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace , target: nil, action: nil)
                fixedSpace.width = -5
                let setCahshingSumButton:UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(STMDebtsPVC_iPhone.setCashingSum))
                let summ = STMCashingProcessController.sharedInstance().debtsSumm()
                let limit = STMCashingProcessController.sharedInstance().cashingSummLimit
                let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter()
                let sumString = numberFormatter.string(from: summ!)!
                setCahshingSumButton.title = numberFormatter.string(from: limit!)
                summLabel.text = String(format: NSLocalizedString("RECEIVE2",comment: ""), arguments: [sumString])
                summLabel.sizeToFit()
                self.setToolbarItems([flexibleSpace,UIBarButtonItem(customView: summLabel),fixedSpace,setCahshingSumButton,flexibleSpace],animated: true)
            case .default:
                self.setToolbarItems([flexibleSpace,self.cashingButton,flexibleSpace], animated: true)
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
        let number = numberFormatter().number(from: textField.text!)
        textField.text = numberFormatter().string(from: number!)
        if number != nil && number!.doubleValue>0{
            STMCashingProcessController.sharedInstance().cashingSummLimit = NSDecimalNumber(decimal: number!.decimalValue)
        }
        updateCashingLabel()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let numberFormatter = STMFunctions.decimalMaxTwoDigitFormatter()
        let text = textField.text!.mutableCopy()
        (text as AnyObject).replaceCharacters(in: range, with:string)
        let textParts = (text as AnyObject).components(separatedBy: numberFormatter.decimalSeparator)
        let decimalPart:String? = textParts.count == 2 ? textParts[1] : nil
        if decimalPart?.characters.count == 3 && string != "" {
            return false
        } else {
            let _ = (text as AnyObject).replaceOccurrences(of: numberFormatter.groupingSeparator, with: "", options: .caseInsensitive, range: NSMakeRange(0, (text as AnyObject).length))
            self.fillTextField(textField, withText: text as! String)
            return false
        }
    }
    
    func fillTextField(_ textField:UITextField, withText text:String) {
        let numberFormatter = STMFunctions.decimalMaxTwoDigitFormatter()
        let number = numberFormatter.number(from: text)
        if number == nil {
            if text == "" {
                textField.text = text
            }
        } else {
            if number!.doubleValue == 0 {
                textField.text = text
            } else {
                var finalString = numberFormatter.string(from: number!)
                var appendingString:String? = nil
                var suffix:String? = nil
                for i in 0...2 {
                    suffix = numberFormatter.decimalSeparator
                    for _ in 0..<i {
                        suffix = suffix! + "0"
                    }
                    appendingString = text.hasSuffix(suffix!) ? suffix : appendingString
                }
                finalString = appendingString != nil ? finalString! + appendingString! : finalString
                textField.text = finalString
            }
        }
    }
    
    //MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for PC: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: Selectors
    
    func changeDate(){
        let popoverContent = self.storyboard!.instantiateViewController(withIdentifier: "datePickerVC") as! STMDatePickerVC
        popoverContent.parentVC = self
        popoverContent.selectedDate = STMCashingProcessController.sharedInstance().selectedDate
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.navigationBar.isHidden = true
        nav.modalPresentationStyle = .popover
        let popover = nav.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 388,height: 205)
        popover?.delegate = self
        popover?.sourceView = self.view
        var frame = dateButton.frame
        frame.origin.y -= 60
        popover?.sourceRect = frame
        self.present(nav, animated: true, completion: nil)
    }
    
    func setCashingSum(){
        var cashingSum: UITextField?
        let alertController = UIAlertController(title: NSLocalizedString("CASHING SUMM", comment: ""), message: nil, preferredStyle: .alert)
        let done = UIAlertAction(title: NSLocalizedString("DONE", comment: ""), style: .default){ (action) -> Void in
            let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
            let number = numberFormatter().number(from: alertController.textFields![0].text!)
            if number != nil{
                STMCashingProcessController.sharedInstance().cashingSummLimit = NSDecimalNumber(decimal: number!.decimalValue)
            }
            if number == 0 || number == nil {
                STMCashingProcessController.sharedInstance().cashingSummLimit = nil
            }
            self.updateCashingLabel()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(done)
        alertController.addAction(cancel)
        alertController.addTextField { (textField) -> Void in
            let numberFormatter = STMFunctions.decimalMaxTwoMinTwoDigitFormatter
            var number = ""
            if STMCashingProcessController.sharedInstance().cashingSummLimit != nil{
                number = numberFormatter().string(from: STMCashingProcessController.sharedInstance().cashingSummLimit)!
            }
            cashingSum = textField
            cashingSum?.placeholder = NSLocalizedString("CASHING SUMM PLACEHOLDER", comment: "")
            cashingSum?.delegate = self
            cashingSum?.text = number
            cashingSum?.clearButtonMode = .always
        }
        present(alertController, animated: true, completion: nil)
    }
    
    func updateCashingLabel() {
        if STMCashingProcessController.sharedInstance().debtsArray.count == 0{
            toolbar = .setCashing
        }else if STMCashingProcessController.sharedInstance().cashingSummLimit == nil{
            toolbar = .cashingSum
        }
        else{
            toolbar = .limitedSum
        }
    }
    
    // MARK: Observers
    
    override func addObservers(){
        super.addObservers()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(STMDebtsPVC_iPhone.updateCashingLabel),
            name: NSNotification.Name(rawValue: "debtAdded"),
            object: STMCashingProcessController.sharedInstance())
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(STMDebtsPVC_iPhone.updateCashingLabel),
            name: NSNotification.Name(rawValue: "debtRemoved"),
            object: STMCashingProcessController.sharedInstance())
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        removeSwipeGesture()
        doneButton = STMBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .done, target: self, action: #selector(STMDebtsDetailsPVC.cashingButtonPressed))
        cancelButton = STMBarButtonItem(title: NSLocalizedString("CANCEL", comment: ""), style: .plain, target:STMCashingProcessController.sharedInstance(), action:#selector(STMCashingProcessController.cancelCashingProcess))
        dateButton.addTarget(self, action: #selector(STMDebtsPVC_iPhone.changeDate), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        toolbar.reset()
    }
    
}
