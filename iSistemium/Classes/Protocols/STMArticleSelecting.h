//
//  STMArticleSelecting.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STMArticleSelecting <NSObject>

- (void)selectArticle:(STMArticle *)article withSearchedBarcode:(NSString *)barcode;


@end
