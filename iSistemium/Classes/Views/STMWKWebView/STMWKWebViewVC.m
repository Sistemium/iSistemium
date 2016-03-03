//
//  STMWKWebViewVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMWKWebViewVC.h"
#import <WebKit/WebKit.h>

#import "STMStoryboard.h"
#import "STMFunctions.h"


@interface STMWKWebViewVC () <WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;


@end


@implementation STMWKWebViewVC

- (NSString *)webViewUrlString {
    
    if ([self.storyboard isKindOfClass:[STMStoryboard class]]) {
        
        STMStoryboard *storyboard = (STMStoryboard *)self.storyboard;
        NSString *url = storyboard.parameters[@"url"];
        return url;
        
    } else {
        
        return @"https://sistemium.com";
        
    }
    
}

- (void)loadWebView {
    
    NSURL *url = [NSURL URLWithString:[self webViewUrlString]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //    NSLog(@"currentDiskUsage %d", [NSURLCache sharedURLCache].currentDiskUsage);
    //    NSLog(@"currentMemoryUsage %d", [NSURLCache sharedURLCache].currentMemoryUsage);
    
    [self.webView loadRequest:request];
    
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"------ didFinishNavigation %@", webView.URL);
    
    [webView evaluateJavaScript:@"document.getElementsByClassName('jumbotron')[0].innerText;" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
        if (result) NSLog(@"evaluateJavaScript with result %@", result);
        if (error) NSLog(@"evaluateJavaScript with error %@", error.localizedDescription);
        
    }];
    
}


#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"userContentController %@, message %@", userContentController, message);
}


#pragma mark - webViewInit

- (void)webViewInit {
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@""];
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
