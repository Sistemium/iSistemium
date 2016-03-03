//
//  STMWKWebViewVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMWKWebViewVC.h"
#import <WebKit/WebKit.h>

#import "STMSessionManager.h"
#import "STMAuthController.h"

#import "STMStoryboard.h"
#import "STMFunctions.h"
#import "STMUI.h"


@interface STMWKWebViewVC () <WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic) BOOL isAuthorizing;
@property (nonatomic, strong) STMSpinnerView *spinnerView;


@end


@implementation STMWKWebViewVC

- (STMSpinnerView *)spinnerView {
    
    if (!_spinnerView) {
        _spinnerView = [STMSpinnerView spinnerViewWithFrame:self.view.frame];
    }
    return _spinnerView;
    
}

- (NSDictionary *)webViewSettings {
    
    NSDictionary *settings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"webview"];
    return settings;
    
}

- (NSString *)webViewUrlString {
    
    if ([self.storyboard isKindOfClass:[STMStoryboard class]]) {
        
        STMStoryboard *storyboard = (STMStoryboard *)self.storyboard;
        NSString *url = storyboard.parameters[@"url"];
        return url;
        
    } else {
        
        return @"https://sistemium.com";
        
    }
    
}

- (NSString *)webViewSessionCheckJS {
    
    if ([self.storyboard isKindOfClass:[STMStoryboard class]]) {
        
        STMStoryboard *storyboard = (STMStoryboard *)self.storyboard;
        NSString *authCheck = storyboard.parameters[@"authCheck"];
        return authCheck;
        
    } else {
        return [[self webViewSettings] valueForKey:@"wv.session.check"];
    }
    
}


- (void)loadWebView {
    
    [self.view addSubview:self.spinnerView];
    
    self.isAuthorizing = NO;
    
    NSString *urlString = [self webViewUrlString];
    [self loadURLString:urlString];
    
}

- (void)authLoadWebView {
    
    self.isAuthorizing = YES;
    
    NSString *accessToken = [STMAuthController authController].accessToken;
    
    //    NSLog(@"accessToken %@", accessToken);
    
    NSString *urlString = [self webViewUrlString];
    urlString = [NSString stringWithFormat:@"%@?access-token=%@", urlString, accessToken];
    
    [self loadURLString:urlString];
    
}

- (void)loadURLString:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //    NSLog(@"currentDiskUsage %d", [NSURLCache sharedURLCache].currentDiskUsage);
    //    NSLog(@"currentMemoryUsage %d", [NSURLCache sharedURLCache].currentMemoryUsage);
    
    NSLog(@"cachedResponseForRequest %@", [[NSURLCache sharedURLCache] cachedResponseForRequest:request]);
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    [self.webView loadRequest:request];
    
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"------ didFinishNavigation %@", webView.URL);
    
    [self.webView evaluateJavaScript:[self webViewSessionCheckJS] completionHandler:^(id result, NSError *error) {
        
        NSString *resultString = nil;
        
        if (!error) {
            
            if (result) {
                
                resultString = [NSString stringWithFormat:@"%@", result];
                
                NSString *bsAccessToken = resultString;
                NSLog(@"bsAccessToken %@", bsAccessToken);
                
                if ([bsAccessToken isEqualToString:@""] || [result isKindOfClass:[NSNull class]]) {
                    
                    if (!self.isAuthorizing) {
                        
                        NSLog(@"no bsAccessToken, go to authorization");
                        
                        [self authLoadWebView];
                        
                    }
                    
                } else {
                    
                    self.isAuthorizing = NO;
                    [self.spinnerView removeFromSuperview];
                    
                }
                
            }
            
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        
    }];
    
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"userContentController %@, message %@", userContentController, message);
    
    if ([message.name isEqualToString:@"post"]) {
        
        NSLog(@"POST");
        
    } else if ([message.name isEqualToString:@"get"]) {

        NSLog(@"GET");

    }
    
}


#pragma mark - webViewInit

- (void)webViewInit {
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@"post"];
    [contentController addScriptMessageHandler:self name:@"get"];

    configuration.userContentController = contentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
    [self.view addSubview:self.webView];
    
    self.webView.navigationDelegate = self;
    [self loadWebView];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    [self webViewInit];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    
    if ([STMFunctions shouldHandleMemoryWarningFromVC:self]) {
        [STMFunctions nilifyViewForVC:self];
    }
    
    [super didReceiveMemoryWarning];
    
}


@end
