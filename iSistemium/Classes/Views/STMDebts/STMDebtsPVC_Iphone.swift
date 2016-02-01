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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegmentedControl()
        removeSwipeGesture()
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
        popoverContent.preferredContentSize = CGSizeMake(388,256)
        popover?.delegate = self
        popover?.sourceView = self.view
        var frame = (self.addDebtButton.valueForKey("view") as! UIView).frame
        frame.origin.y -= 44
        popover?.sourceRect = frame
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
}
