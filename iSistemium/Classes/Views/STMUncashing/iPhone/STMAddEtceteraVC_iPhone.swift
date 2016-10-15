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
        self.dismiss(animated: true, completion: nil)
    }
    
    func addButtonPressed() {
        super.doneButtonPressed(nil)
        if super.textFieldFillingIsCorrect(){
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
        switch (cashingType){
        case .deduction:
            self.title = NSLocalizedString("DEDUCTION", comment: "")
        case .etcetera:
            self.title = NSLocalizedString("ETC", comment: "")
            break
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("CLOSE", comment: ""), style: .plain, target: self, action: #selector(STMAddEtceteraVC_iPhone.closeButtonPressed))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("ADD", comment: ""), style: .plain, target: self, action: #selector(STMAddEtceteraVC_iPhone.addButtonPressed))
    }
    
}
