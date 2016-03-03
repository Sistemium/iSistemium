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
#import "STMBarCodeScanner.h"
#import "STMSoundController.h"
#import "STMObjectsController.h"

#import "STMStoryboard.h"
#import "STMFunctions.h"
#import "STMUI.h"


#define WK_MESSAGE_POST @"post"
#define WK_MESSAGE_GET @"get"
#define WK_MESSAGE_SCANNER_ON @"barCodeScannerOn"
#define WK_MESSAGE_FIND_ALL @"findAll"
#define WK_MESSAGE_FIND @"find"


@interface STMWKWebViewVC () <WKNavigationDelegate, WKScriptMessageHandler, STMBarCodeScannerDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic) BOOL isAuthorizing;
@property (nonatomic, strong) STMSpinnerView *spinnerView;

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic, strong) NSString *receiveBarCodeJSFunction;
@property (nonatomic, strong) NSString *iSistemiumIOSCallbackJSFunction;
@property (nonatomic, strong) NSString *iSistemiumIOSErrorCallbackJSFunction;


@end


@implementation STMWKWebViewVC

- (NSString *)iSistemiumIOSCallbackJSFunction {
    return @"iSistemiumIOSCallback";
}

- (NSString *)iSistemiumIOSErrorCallbackJSFunction {
    return @"iSistemiumIOSErrorCallback";
}

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

- (NSString *)webViewAuthCheckJS {
    
    if ([self.storyboard isKindOfClass:[STMStoryboard class]]) {
        
        STMStoryboard *storyboard = (STMStoryboard *)self.storyboard;
        NSString *authCheck = storyboard.parameters[@"authCheck"];
        return authCheck;
        
    } else {
        return [[self webViewSettings] valueForKey:@"wv.session.check"];
    }
    
}

- (void)reloadWebView {
    
    [self.webView removeFromSuperview];
    self.webView = nil;
    [self webViewInit];

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

- (NSArray *)scriptMessageNames {
    
    return @[WK_MESSAGE_POST,
             WK_MESSAGE_GET,
             WK_MESSAGE_SCANNER_ON,
             WK_MESSAGE_FIND_ALL,
             WK_MESSAGE_FIND];
    
}


#pragma mark - webViewInit

- (void)webViewInit {
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    
    for (NSString *messageName in [self scriptMessageNames]) {
        [contentController addScriptMessageHandler:self name:messageName];
    }
    
    configuration.userContentController = contentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    
    [self.view addSubview:self.webView];
    
    self.webView.navigationDelegate = self;
    [self loadWebView];
    
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"---- webView decidePolicyForNavigationAction");
    
    NSLog(@"scheme %@", navigationAction.request.URL.scheme);
    NSLog(@"request %@", navigationAction.request)
    NSLog(@"HTTPMethod %@", navigationAction.request.HTTPMethod)
    NSLog(@"HTTPBody %@", navigationAction.request.HTTPBody)
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"------ didFinishNavigation %@", webView.URL);
    
    NSString *authCheck = [self webViewAuthCheckJS];
    
    (authCheck) ? [self authCheckWithJS:authCheck] : [self.spinnerView removeFromSuperview];
    
}

- (void)authCheckWithJS:(NSString *)authCheck {
    
    [self.webView evaluateJavaScript:authCheck completionHandler:^(id result, NSError *error) {
        
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
    
    NSLog(@"---- userContentController %@, message %@", userContentController, message);
    NSLog(@"message.name %@", message.name);
    NSLog(@"message.body %@", message.body);
    
    if ([message.name isEqualToString:WK_MESSAGE_POST]) {
        
        NSLog(@"POST");
        
    } else if ([message.name isEqualToString:WK_MESSAGE_GET]) {

        NSLog(@"GET");

    } else if ([message.name isEqualToString:WK_MESSAGE_SCANNER_ON]) {

        [self startBarcodeScanning];
        self.receiveBarCodeJSFunction = message.body;
        
    } else if ([message.name isEqualToString:WK_MESSAGE_FIND_ALL]) {
        
        
    } else if ([message.name isEqualToString:WK_MESSAGE_FIND]) {
        
        
    }
    
}

- (void)handleFindAllMessage:(WKScriptMessage *)message {
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *parameters = message.body;
        
        NSError *error;
        NSString *objectsString = [STMObjectsController findAllObjectsWithParameters:parameters error:&error];
        
        if (!error) {
            
            [self callbackWithData:objectsString parameters:[STMFunctions jsonStringFromDictionary:parameters]];
            
        } else {
            
            [self callbackWithError:error.localizedDescription parameters:[STMFunctions jsonStringFromDictionary:parameters]];
            
        }
        
    } else {
        
        [self callbackWithError:@"message.body is not a NSDictionary class" parameters:[message.body description]];
        
    }

}

- (void)callbackWithData:(NSString *)data parameters:(NSString *)parameters {
    
    NSMutableArray *arguments = @[].mutableCopy;
    
    [arguments addObject:data];
    [arguments addObject:parameters];
    
    NSString *jsFunction = [NSString stringWithFormat:@"%@(%@)", self.iSistemiumIOSCallbackJSFunction, [arguments componentsJoinedByString:@","]];
    
    [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    
}

- (void)callbackWithError:(NSString *)errorDescription parameters:(NSString *)parameters {
    
    NSMutableArray *arguments = @[].mutableCopy;
    
    [arguments addObject:errorDescription];
    [arguments addObject:parameters];
    
    NSString *jsFunction = [NSString stringWithFormat:@"%@(%@)", self.iSistemiumIOSErrorCallbackJSFunction, [arguments componentsJoinedByString:@","]];
    
    [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];

}


#pragma mark - barcode scanning

- (void)startBarcodeScanning {
    [self startIOSModeScanner];
}

- (void)startIOSModeScanner {
    
    self.iOSModeBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerIOSMode];
    self.iOSModeBarCodeScanner.delegate = self;
    [self.iOSModeBarCodeScanner startScan];
    
    if ([self.iOSModeBarCodeScanner isDeviceConnected]) {
        [self scannerIsConnected];
    }
    
}

- (void)stopBarcodeScanning {
    [self stopIOSModeScanner];
}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;
    
    [self scannerIsDisconnected];
    
}

- (void)scannerIsConnected {

}

- (void)scannerIsDisconnected {
    
}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCodeScan:(STMBarCodeScan *)barCodeScan withType:(STMBarCodeScannedType)type {
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    if (self.isInActiveTab) {
        
        NSMutableArray *arguments = @[].mutableCopy;

        [arguments addObject:barcode];
        
        NSString *typeString = [STMBarCodeController barCodeTypeStringForType:type];
        
        if (typeString) [arguments addObject:typeString];
        
        NSString *jsFunction = [NSString stringWithFormat:@"%@(%@)", self.receiveBarCodeJSFunction, [arguments componentsJoinedByString:@","]];
        
        [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
        }];
        
    }
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE ARRIVAL", nil)];
        
        [self scannerIsConnected];
        
    }
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE REMOVAL", nil)];
        
        [self scannerIsDisconnected];
        
    }
    
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
