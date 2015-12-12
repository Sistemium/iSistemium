//
//  STMSupplyOrderArticleDocsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

@interface STMSupplyOrderArticleDocsTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMSupplyOrder *supplyOrder;

- (void)selectSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)articleDoc;


@end
