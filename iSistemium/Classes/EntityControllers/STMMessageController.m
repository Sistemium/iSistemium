//
//  STMMessageController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMMessageController.h"
#import "STMMessageVC.h"
#import "STMRootTBC.h"

@implementation STMMessageController

+ (void)showMessageVCsForMessage:(STMMessage *)message {
    
    UIViewController *presenter = [STMRootTBC sharedRootVC];
    
    for (STMMessagePicture *picture in message.pictures) {
        
        UIImage *image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];
        STMMessageVC *messageVC = [self messageVCWithImage:image andText:message.body];
        [presenter presentViewController:messageVC animated:NO completion:nil];
        
        presenter = messageVC;

        STMMessageVC *messageVC1 = [self messageVCWithImage:image andText:@"SECOND VC"];
        [presenter presentViewController:messageVC1 animated:NO completion:nil];

    }
    
}

+ (STMMessageVC *)messageVCWithImage:(UIImage *)image andText:(NSString *)text {
    
    UIStoryboard *messageVCStoryboard = [UIStoryboard storyboardWithName:@"STMMessageVC" bundle:nil];
    STMMessageVC *messageVC = [messageVCStoryboard instantiateInitialViewController];
    
    messageVC.image = image;
    messageVC.text = text;
    
    return messageVC;

}

@end
