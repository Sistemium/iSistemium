//
//  STMWebViewVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMWebViewVC.h"

@interface STMWebViewVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation STMWebViewVC

- (void)loadWebView {
    
    NSURL *url = [NSURL URLWithString:@"http://yandex.ru"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    
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
