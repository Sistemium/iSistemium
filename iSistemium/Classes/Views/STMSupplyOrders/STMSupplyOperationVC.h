//
//  STMSupplyOperationVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMDataModel.h"
#import "STMSupplyOrderOperationsTVC.h"


@interface STMSupplyOperationVC : UIViewController

@property (nonatomic, strong) STMSupplyOrderArticleDoc *supplyOrderArticleDoc;
@property (nonatomic, strong) STMStockBatchOperation *supplyOperation;

@property (nonatomic, weak) STMSupplyOrderOperationsTVC *parentTVC;

@property (nonatomic, strong) NSString *initialBarcode;

- (void)addStockBatchCode:(NSString *)code;


@end
