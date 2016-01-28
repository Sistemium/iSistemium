//
//  STMDebtsDetailsPVC_Iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 26/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMDebtsPVC_Iphone: STMDebtsDetailsPVC{
    override var outlet:STMOutlet?{
        didSet{
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupSegmentedControl()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        //self.setToolbarItems([self.editDebtsButton, flexibleSpace, self.addDebtButton], animated: true)
        self.setToolbarItems([flexibleSpace,self.cashingButton,flexibleSpace], animated: true)
        self.addDebtButton = UIBarButtonItem(barButtonSystemItem: .Add, target:self, action:"addDebtButtonPressed:")
        self.navigationItem.rightBarButtonItem = self.addDebtButton;
    }
}
