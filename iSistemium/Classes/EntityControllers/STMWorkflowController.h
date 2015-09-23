//
//  STMWorkflowController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/09/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"

@interface STMWorkflowController : STMController

+ (UIActionSheet *)workflowActionSheetForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow;


@end
