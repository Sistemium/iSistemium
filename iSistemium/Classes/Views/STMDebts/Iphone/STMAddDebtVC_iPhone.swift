//
//  STMAddDebtVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 01/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMAddDebtVC_iPhone: STMAddDebtVC,UIPopoverPresentationControllerDelegate {
    
    // MARK: Selectors
    
    func closeButtonPressed(){
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func addButtonPressed() {
        super.doneButtonPressed(nil)
        if debtNdoc ?? "" != "" && debtSum ?? 0 != 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for PC: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!){
        case "showDatePicker":
            let datePickerVC = segue.destination as! STMDatePickerVC
            datePickerVC.preferredContentSize = CGSize(width: 450,height: 250)
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
        self.title = NSLocalizedString("ADD DEBT", comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CLOSE", comment: ""), style: .plain, target: self, action: #selector(STMAddDebtVC_iPhone.closeButtonPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("ADD", comment: ""), style: .plain, target: self, action: #selector(STMAddDebtVC_iPhone.addButtonPressed))
    }
    
}
