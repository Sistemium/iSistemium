//
//  STMStockBatchOperationController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMStockBatchOperationController : STMController

+ (STMStockBatchOperation *)stockBatchOperationWithSource:(STMStockBatchOperationAgent *)source
                                              destination:(STMStockBatchOperationAgent *)destination
                                                   volume:(NSNumber *)volume
                                                     save:(BOOL)save;

+ (STMStockBatchOperation *)findStockBatchOperationWithSource:(STMStockBatchOperationAgent *)source
                                               andDestination:(STMStockBatchOperationAgent *)destination;


@end
