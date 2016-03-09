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

#import "iSistemium-Swift.h"


@interface STMWKWebViewVC () <WKNavigationDelegate, WKScriptMessageHandler, STMBarCodeScannerDelegate>

@property (weak, nonatomic) IBOutlet UIView *localView;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic) BOOL isAuthorizing;
@property (nonatomic, strong) STMSpinnerView *spinnerView;

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic, strong) NSString *receiveBarCodeJSFunction;
@property (nonatomic, strong) NSString *iSistemiumIOSCallbackJSFunction;
@property (nonatomic, strong) NSString *iSistemiumIOSErrorCallbackJSFunction;


@end


@implementation STMWKWebViewVC

- (BOOL)isInActiveTab {
    return [self.tabBarController.selectedViewController isEqual:self.navigationController];
}


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
    [self.webView reloadFromOrigin];
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
             WK_MESSAGE_FIND,
             WK_MESSAGE_SOUND,
             WK_MESSAGE_UPDATE_ALL];
    
}


#pragma mark - webViewInit

- (void)webViewInit {
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    
    for (NSString *messageName in [self scriptMessageNames]) {
        [contentController addScriptMessageHandler:self name:messageName];
    }
    
    configuration.userContentController = contentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.localView.bounds configuration:configuration];
    
    [self.localView addSubview:self.webView];
    
    self.webView.navigationDelegate = self;
    [self loadWebView];
    
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    NSLogMethodName;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    NSLogMethodName;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    NSLogMethodName;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
//    NSLogMethodName;
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
//    NSLogMethodName;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
//    NSLogMethodName;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
//    NSLogMethodName;
    decisionHandler(WKNavigationResponsePolicyAllow);
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
//    NSLog(@"---- webView decidePolicyForNavigationAction");
//    
//    NSLog(@"scheme %@", navigationAction.request.URL.scheme);
//    NSLog(@"request %@", navigationAction.request)
//    NSLog(@"HTTPMethod %@", navigationAction.request.HTTPMethod)
//    NSLog(@"HTTPBody %@", navigationAction.request.HTTPBody)
    
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
    
#ifdef DEBUG
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSString *requestId = message.body[@"options"][@"requestId"];
        NSLog(@"%@ requestId: %@", message.name, requestId);

    } else {

        NSLog(@"%@ %@", message.name, message.body);

    }
    
#endif

    
    if ([message.name isEqualToString:WK_MESSAGE_POST]) {
        
        NSLog(@"POST");
        
    } else if ([message.name isEqualToString:WK_MESSAGE_GET]) {

        NSLog(@"GET");

    } else if ([message.name isEqualToString:WK_MESSAGE_UPDATE_ALL]) {
        
        [self handleUpdateAllMessage:message];
        
    } else if ([message.name isEqualToString:WK_MESSAGE_SOUND]) {
        
        [self handleSoundMessage:message];
        
    } else if ([message.name isEqualToString:WK_MESSAGE_SCANNER_ON]) {

        [self startBarcodeScanning];
        self.receiveBarCodeJSFunction = message.body;
        
    } else if ([@[WK_MESSAGE_FIND_ALL, WK_MESSAGE_FIND] containsObject:message.name]) {
        
        [self handleKindOfFindMessage:message];
        
    }
    
}

- (void)handleUpdateAllMessage:(WKScriptMessage *)message {
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *parameters = message.body;

        NSLog(@"%@", parameters);
        
        NSError *error = nil;
        NSArray *result = [STMObjectsController updateObjectsFromScriptMessage:message error:&error];
        
        if (!error) {
            
            // send updated objects to webView
            
        } else {
            
            [self callbackWithError:error.localizedDescription
                         parameters:parameters];
            
        }
        
    } else {
        
        [self callbackWithError:@"message.body is not a NSDictionary class"
                     parameters:@{@"messageBody": [message.body description]}];

    }
    
}

- (void)handleSoundMessage:(WKScriptMessage *)message {
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *parameters = message.body;

        NSString *messageSound = parameters[@"sound"];
        NSString *messageText = parameters[@"text"];

        float rate = (parameters[@"rate"]) ? [parameters[@"rate"] floatValue] : 0.5;
        float pitch = (parameters[@"pitch"]) ? [parameters[@"pitch"] floatValue] : 1;
        
        if (messageSound) {
            
            if ([messageSound isEqualToString:@"alert"]) {
                
                (messageText) ? [STMSoundController alertSay:messageText withRate:rate pitch:pitch] : [STMSoundController playAlert];
                
            } else if ([messageSound isEqualToString:@"ok"]) {
                
                (messageText) ? [STMSoundController okSay:messageText withRate:rate pitch:pitch] : [STMSoundController playOk];
                
            } else {
                
                [self callbackWithError:@"unknown sound parameter"
                             parameters:parameters];
                
                (messageText) ? [STMSoundController sayText:messageText withRate:rate pitch:pitch] : nil;
                
            }

        } else if (messageText) {
            
            [STMSoundController sayText:messageText withRate:rate pitch:pitch];

        } else {
            
            [self callbackWithError:@"message.body have no text ot sound to play"
                         parameters:parameters];

        }

    } else {
        
        [self callbackWithError:@"message.body is not a NSDictionary class"
                     parameters:@{@"messageBody": [message.body description]}];
        
    }
    
}

- (void)handleKindOfFindMessage:(WKScriptMessage *)message {
    
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *parameters = message.body;
        
        NSError *error = nil;

        NSArray *result = [STMObjectsController arrayOfObjectsRequestedByScriptMessage:message error:&error];

        if (!error) {
            
            [self callbackWithData:result
                        parameters:parameters];
            
        } else {
            
            [self callbackWithError:error.localizedDescription
                         parameters:parameters];
            
        }
        
    } else {
        
        [self callbackWithError:@"message.body is not a NSDictionary class"
                     parameters:@{@"messageBody": [message.body description]}];
        
    }

}

- (void)callbackWithData:(NSArray *)data parameters:(NSDictionary *)parameters {
    
#ifdef DEBUG
    
    NSString *requestId = parameters[@"options"][@"requestId"];
    NSLog(@"requestId %@ callbackWithData: %@ objects", requestId, @(data.count));
    
#endif

    NSMutableArray *arguments = @[].mutableCopy;
    
    [arguments addObject:data];
    [arguments addObject:parameters];
    
    NSString *jsFunction = [NSString stringWithFormat:@"%@.apply(null,%@)", self.iSistemiumIOSCallbackJSFunction, [STMFunctions jsonStringFromArray:arguments]];
    
    [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
    
}

- (void)callbackWithError:(NSString *)errorDescription parameters:(NSDictionary *)parameters {
    
#ifdef DEBUG

    NSString *requestId = parameters[@"options"][@"requestId"];
    
    if (requestId) {
        NSLog(@"requestId %@ callbackWithError: %@", requestId, errorDescription);
    } else {
        NSLog(@"callbackWithError: %@ for message parameters: %@", errorDescription, parameters);
    }
    
#endif

    NSMutableArray *arguments = @[].mutableCopy;
    
    [arguments addObject:errorDescription];
    [arguments addObject:parameters];
    
    NSString *jsFunction = [NSString stringWithFormat:@"%@.apply(null.%@)", self.iSistemiumIOSErrorCallbackJSFunction, [STMFunctions jsonStringFromArray:arguments]];
    
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

    if (self.isInActiveTab) {
        
        NSMutableArray *arguments = @[].mutableCopy;

        NSString *barcode = barCodeScan.code;
        if (!barcode) barcode = @"";
        [arguments addObject:barcode];
        
        NSString *typeString = [STMBarCodeController barCodeTypeStringForType:type];
        if (!typeString) typeString = @"";
        [arguments addObject:typeString];
        
        NSDictionary *barcodeDic = [STMObjectsController dictionaryForJSWithObject:barCodeScan];
        [arguments addObject:barcodeDic];
        
        NSLog(@"send received barcode %@ with type %@ to WKWebView", barcode, typeString);
        
        NSString *jsFunction = [NSString stringWithFormat:@"%@.apply(null,%@)", self.receiveBarCodeJSFunction, [STMFunctions jsonStringFromArray:arguments]];
        
        [self.webView evaluateJavaScript:jsFunction completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
        }];

    }

}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    if (self.isInActiveTab) {
        
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

- (void) viewDidAppear:(BOOL)animated {
    if (self.iOSModeBarCodeScanner) {
        self.iOSModeBarCodeScanner.delegate = self;
    }
}


@end
