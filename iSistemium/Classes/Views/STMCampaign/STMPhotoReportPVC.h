//
//  STMPhotoReportPVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMPhotoReport.h"

#import "STMCampaignPhotoReportCVC.h"

@interface STMPhotoReportPVC : UIPageViewController

@property (nonatomic, strong) STMPhotoReport *photoReport;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photoArray;

@property (nonatomic, weak) STMCampaignPhotoReportCVC *parentVC;


@end
