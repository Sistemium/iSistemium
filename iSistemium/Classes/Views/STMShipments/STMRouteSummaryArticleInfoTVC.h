//
//  STMRouteSummaryArticleInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"


@interface STMRouteSummaryArticleInfoTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMArticle *article;
@property (nonatomic, strong) NSArray *positions;

@property (nonatomic, strong) NSString *volumeType;


@end
