//
//  STMUncashingInfoVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 15/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingInfoVC_iPhone: STMUncashingInfoVC {
    
    @IBAction func cancelButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(){
        STMUncashingProcessController.sharedInstance().uncashingDone()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.commentTextView?.sizeToFit()
        self.preferredContentSize = CGSizeMake(500,150 + self.commentTextView!.contentSize.height)
    }
    
}
