//
//  STMSupplyOrdersProcessController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMSupplyOrdersProcessController : STMController

+ (void)createOperationForSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)supplyOrderArticleDoc
                                      withCodes:(NSArray *)codes
                                      andVolume:(NSInteger)volume;

+ (void)changeOperation:(STMStockBatchOperation *)operation
              newVolume:(NSInteger)newVolume;


@end
