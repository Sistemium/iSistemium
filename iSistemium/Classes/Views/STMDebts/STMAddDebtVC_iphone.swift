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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
