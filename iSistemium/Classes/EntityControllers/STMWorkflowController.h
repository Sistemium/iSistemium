//
//  STMWorkflowController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/09/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMUI.h"


@interface STMWorkflowController : STMController

+ (STMWorkflowAS *)workflowActionSheetForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow withDelegate:(id <UIActionSheetDelegate>)delegate;

+ (void)workflowActionSheetDidSelectButtonWithIndex:(NSInteger)buttonIndex inWorkflow:(NSString *)workflow;


@end
