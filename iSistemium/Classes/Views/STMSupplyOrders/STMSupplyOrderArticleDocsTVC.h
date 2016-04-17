//
//  STMSupplyOrderArticleDocsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSearchableTVC.h"
#import "STMDataModel.h"

@interface STMSupplyOrderArticleDocsTVC : STMSearchableTVC

@property (nonatomic, strong) STMSupplyOrder *supplyOrder;

- (void)highlightSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)articleDoc;

- (void)orderProcessingChanged;


@end
