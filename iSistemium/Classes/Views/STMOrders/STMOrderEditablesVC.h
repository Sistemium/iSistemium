//
//  STMOrderEditablesVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMOrderEditablesVC : UIViewController

@property (nonatomic, strong) NSArray *editableFields;
@property (nonatomic, strong) NSString *fromProcessing;
@property (nonatomic, strong) NSString *toProcessing;


@end
