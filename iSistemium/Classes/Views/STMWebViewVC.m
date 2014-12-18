//
//  STMWebViewVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMWebViewVC.h"
#import "STMSessionManager.h"
#import "STMAuthController.h"

@interface STMWebViewVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation STMWebViewVC

- (NSDictionary *)webViewSettings {
    
    NSDictionary *settings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"webview"];
    return settings;
    
}

- (NSString *)webViewUrlString {
    
    return [[self webViewSettings] valueForKey:@"wv.url"];
    
}


- (void)loadWebView {

    NSString *accessToken = [STMAuthController authController].accessToken;
    
    NSString *urlString = [self webViewUrlString];
    urlString = @"https://sis.bis100.ru/bs/tp/";
    
//    urlString = [NSString stringWithFormat:@"%@?access-token=%@", urlString, accessToken];
    
    NSLog(@"urlString %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [self.webView loadRequest:request];
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"cookie %@", cookie);
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self loadWebView];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}

@end
