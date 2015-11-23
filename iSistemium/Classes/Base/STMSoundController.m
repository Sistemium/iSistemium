//
//  STMSoundController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSoundController.h"

#import <AVFoundation/AVFoundation.h>


@interface STMSoundController()

@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;


@end

@implementation STMSoundController

+ (STMSoundController *)sharedController {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedController = nil;
    
    dispatch_once(&pred, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {

    }
    return self;
    
}

- (AVSpeechSynthesizer *)speechSynthesizer {
    
    if (!_speechSynthesizer) {
        _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    }
    return _speechSynthesizer;
    
}


#pragma mark - class methods

+ (void)playAlert {
    
//     List of Predefined sounds and it's IDs
//     http://iphonedevwiki.net/index.php/AudioServices
    
    AudioServicesPlayAlertSound(1033);
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

}

+ (void)playOk {
    AudioServicesPlaySystemSound(1003);
}

+ (void)say:(NSString *)string {
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:string];
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    [[self sharedController].speechSynthesizer speakUtterance:utterance];
    
}

+ (void)alertSay:(NSString *)string {
    
    [self playAlert];
    [self say:string];
    
}

+ (void)okSay:(NSString *)string {

    [self playOk];
    [self say:string];

}


@end
