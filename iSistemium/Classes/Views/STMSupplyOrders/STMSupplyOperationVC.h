//
//  STMSupplyOperationVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMDataModel.h"


@interface STMSupplyOperationVC : UIViewController

@property (nonatomic, strong) STMSupplyOrderArticleDoc *supplyOrderArticleDoc;

@property (nonatomic, strong) NSString *initialBarcode;


@end
