//
//  STMAddDebtVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 01/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMAddDebtVC_iphone: STMAddDebtVC {
    
    @IBAction override func cancelButtonPressed(sender:AnyObject){
        super.cancelButtonPressed(sender)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction override func doneButtonPressed(sender:AnyObject) {
        super.doneButtonPressed(sender)
        if debtNdoc ?? "" != "" && debtSum ?? 0 != 0 {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("ADD DEBT", comment: "")
    }
}
