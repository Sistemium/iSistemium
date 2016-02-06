//
//  STMDebtsDetailsPVC_Iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 26/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMDebtsPVC_Iphone: STMDebtsDetailsPVC, UIPopoverPresentationControllerDelegate{
    
    var doneButton:STMBarButtonItem?
    
    var cancelButton:STMBarButtonItem?
    
    let summLabel = UIBarButtonItem(customView: UILabel())
    
    private lazy var addDebt:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target:self, action:"addDebtButtonPressed:")
    
    override func buttonsForVC(vc:UIViewController){
        self.navigationController?.setToolbarHidden(false, animated: true)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        self.setToolbarItems([flexibleSpace,self.cashingButton,flexibleSpace], animated: false)
        self.addDebtButton = addDebt
        self.navigationItem.rightBarButtonItem = self.addDebtButton
        if vc.isKindOfClass(STMOutletCashingVC){
            self.navigationItem.rightBarButtonItem = nil
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
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
        let popoverContent = self.storyboard!.instantiateViewControllerWithIdentifier("addDebtVC") as! STMAddDebtVC_iphone
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
        self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
        self.navigationItem.titleView?.hidden = true
        self.navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        self.setToolbarItems([summLabel],animated: false)
        super.cashingProcessStart()
        STMCashingProcessController.sharedInstance().selectedDate = NSDate() //Delete after date is added
    }
    
    override func cashingProcessDone() {
        super.cashingProcessDone()
        self.navigationItem.titleView?.hidden = false
        self.navigationItem.setLeftBarButtonItem(self.navigationItem.backBarButtonItem, animated: false)
        self.buttonsForVC(self)
    }
    
    func showCashingSumLabel() {
    let summ = STMCashingProcessController.sharedInstance().debtsSumm
    let numberFormatter = STMFunctions.currencyFormatter
    let sumString = numberFormatter().stringFromNumber(summ())
        self.summLabel.title = NSString(format: "%@: %@", NSLocalizedString("PICKED",comment: ""), sumString!) as String
    }
    
    
//    override func cashingProcessCancel() {
//        super.cashingProcessCancel()
//        STMCashingProcessController.sharedInstance().state = .
//    }
    
}
