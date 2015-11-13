//
//  STMPhotoReportVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMDataModel.h"
#import "STMPhotoReportsDetailTVC.h"


@interface STMPhotoReportVC : UIViewController

@property (nonatomic, weak) STMPhotoReport *photoReport;
@property (nonatomic, weak) STMPhotoReportsDetailTVC *parentVC;


@end
