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

@interface STMWebViewVC () <UIWebViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL isAuthorizing;

@end

@implementation STMWebViewVC

- (NSDictionary *)webViewSettings {
    
    NSDictionary *settings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"webview"];
    return settings;
    
}

- (NSString *)webViewUrlString {
    
    return [[self webViewSettings] valueForKey:@"wv.url"];
    
}

- (NSString *)webViewSessionCheckJS {
    
    return [[self webViewSettings] valueForKey:@"wv.session.check"];
    
}

- (NSString *)webViewSessionCookie {
    
    return [[self webViewSettings] valueForKey:@"wv.session.cookie"];
    
}

- (NSString *)webViewTitle {
    
    return [[self webViewSettings] valueForKey:@"wv.title"];
    
}


- (void)loadWebView {

    NSString *urlString = [self webViewUrlString];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [self.webView loadRequest:request];
    
}

- (void)authLoadWebView {

    NSString *accessToken = [STMAuthController authController].accessToken;
    
//    NSLog(@"accessToken %@", accessToken);

    NSString *urlString = [self webViewUrlString];
    urlString = [NSString stringWithFormat:@"%@?access-token=%@", urlString, accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [self.webView loadRequest:request];
    
}

- (void)flushCookie {
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        
        NSLog(@"cookie %@", cookie);
        [cookieJar deleteCookie:cookie];
        
    }

    NSLog(@"cookies %@", [cookieJar cookies]);

}


#pragma mark - STMTabBarViewController

- (void)showActionSheetFromTabBarItem {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"TITLE" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"DO SMTHNG", nil];
    
    CGFloat tabBarYPosition = self.tabBarController.tabBar.frame.origin.y;
    CGRect rect = [[self.tabBarController.tabBar.subviews objectAtIndex:self.tabBarController.selectedIndex+1] frame];
    rect = CGRectMake(rect.origin.x, rect.origin.y + tabBarYPosition, rect.size.width, rect.size.height);
    
    [actionSheet showFromRect:rect inView:self.view animated:YES];
    
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *bsAccessToken = [self.webView stringByEvaluatingJavaScriptFromString:[self webViewSessionCheckJS]];

//    NSLog(@"bsAccessToken %@", bsAccessToken);
    
    if ([bsAccessToken isEqualToString:@""] && !self.isAuthorizing) {
    
        NSLog(@"no bsAccessToken, go to authorization");

        self.isAuthorizing = YES;
        [self authLoadWebView];
        
    }

}


#pragma mark - view lifecycle

- (void)customInit {

//    [self flushCookie];

    self.tabBarItem.title = [self webViewTitle];
    
    self.webView.delegate = self;
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
