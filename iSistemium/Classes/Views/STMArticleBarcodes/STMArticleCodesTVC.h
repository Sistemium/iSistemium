//
//  STMArticleCodesTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"

@interface STMArticleCodesTVC : STMFetchedResultsControllerTVC

@property (nonatomic, weak) STMArticle *article;
@property (nonatomic, weak) NSString *scannedBarcode;


@end
