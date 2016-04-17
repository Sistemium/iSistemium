//
//  STMArticleCodesTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"


@interface STMArticleCodesTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) NSString *scannedBarcode;
@property (nonatomic, weak) STMArticle *selectedArticle;


@end
