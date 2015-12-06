//
//  STMInventoryControlling.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STMDataModel.h"


@protocol STMInventoryControlling <NSObject>

@required

- (void)shouldSelectArticleFromArray:(NSArray <STMArticle *>*)articles;
- (void)shouldSetProductionInfoForArticle:(STMArticle *)article;
- (void)didSuccessfullySelectArticle:(STMArticle *)article;


@end
