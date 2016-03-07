//
//  STMAddEtceteraVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 07/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMAddEtceteraVC_iPhone: STMAddEtceteraVC,UIPopoverPresentationControllerDelegate {
    
    // MARK: Selectors
    
    func closeButtonPressed(){
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addButtonPressed() {
        super.doneButtonPressed(nil)
        if super.textFieldFillingIsCorrect(){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier!){
        case "showDatePicker":
            let datePickerVC = segue.destinationViewController as! STMDatePickerVC
            datePickerVC.preferredContentSize = CGSizeMake(450,250)
            datePickerVC.popoverPresentationController?.delegate = self
            datePickerVC.popoverPresentationController?.sourceRect = dateButton!.frame
            datePickerVC.popoverPresentationController?.sourceRect.origin.x -= 220
            datePickerVC.popoverPresentationController?.sourceRect.origin.y -= 70
            datePickerVC.parentVC = self
            datePickerVC.selectedDate = self.selectedDate
            view.endEditing(true)
        default:
            break
        }
    }
    
    // MARK: view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch (cashingType){
        case .Deduction:
            self.title = NSLocalizedString("DEDUCTION", comment: "")
        case .Etcetera:
            self.title = NSLocalizedString("ETC", comment: "")
            break
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CLOSE", comment: ""), style: .Plain, target: self, action: "closeButtonPressed")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("ADD", comment: ""), style: .Plain, target: self, action: "addButtonPressed")
    }
    
}