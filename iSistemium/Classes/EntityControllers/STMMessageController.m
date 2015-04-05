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

+ (NSArray *)picturesArrayForMessage:(STMMessage *)message {
    
    NSSortDescriptor *picturesSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
    NSArray *picturesArray = [message.pictures sortedArrayUsingDescriptors:@[picturesSortDescriptor]];

    return picturesArray;
    
}

+ (void)showMessageVCsForMessages:(NSArray *)messages {
    
    for (STMMessage *message in messages) {
        [self showMessageVCsForMessage:message];
    }
    
}

+ (void)showMessageVCsForMessage:(STMMessage *)message {
    
    NSArray *picturesArray = [self picturesArrayForMessage:message];
    
    for (STMMessagePicture *picture in picturesArray) {
    
        UIViewController *presenter = [[STMRootTBC sharedRootVC] topmostVC];

        UIImage *image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:picture.imagePath]];
        STMMessageVC *messageVC = [self messageVCWithImage:image andText:message.body];
        [presenter presentViewController:messageVC animated:NO completion:nil];
        
        presenter = [[STMRootTBC sharedRootVC] topmostVC];

        STMMessageVC *messageVC1 = [self messageVCWithImage:image andText:@"SECOND VC"];
        [presenter presentViewController:messageVC1 animated:NO completion:nil];

        presenter = [[STMRootTBC sharedRootVC] topmostVC];
        
        STMMessageVC *messageVC2 = [self messageVCWithImage:image andText:@"THIRD VC"];
        [presenter presentViewController:messageVC2 animated:NO completion:nil];

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
