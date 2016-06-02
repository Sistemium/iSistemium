//
//  STMPhotoReportsDetailTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMPhotoReportsDetailTVC_iphone:STMPhotoReportsDetailTVC{
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
}
