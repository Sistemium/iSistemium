//
//  STMSupplyOrderArticleDoc.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderArticleDoc.h"
#import "STMArticle.h"
#import "STMArticleDoc.h"
#import "STMSupplyOrder.h"

#import "STMFunctions.h"


@implementation STMSupplyOrderArticleDoc

- (NSString *)volumeText {
    
    return [STMFunctions volumeStringWithVolume:self.volume.integerValue
                                  andPackageRel:(self.article.packageRel) ? self.article.packageRel.integerValue : self.articleDoc.article.packageRel.integerValue];
    
}

- (STMArticle *)operatingArticle {
    return (self.article) ? (STMArticle * _Nonnull)self.article : self.articleDoc.article;
}


@end
