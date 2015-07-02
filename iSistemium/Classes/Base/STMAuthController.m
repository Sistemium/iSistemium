//
//  STAuthController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAuthController.h"

#import <AdSupport/AdSupport.h>

#import "STMDevDef.h"
#import "STMFunctions.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"
#import "STMSessionManager.h"
#import "STMLogger.h"


//#define AUTH_URL @"https://sistemium.com/auth.php"
#define AUTH_URL @"https://api.sistemium.com/pha/auth"

#define ROLES_URL @"https://api.sistemium.com/pha/roles"
//#define ROLES_URL @"https://api.sistemium.com/pha/v2/roles" // for crash testing

#define TIMEOUT 15.0

@interface STMAuthController() <NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSString *serviceUri;
@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, strong) KeychainItemWrapper *keychainItem;

@end


@implementation STMAuthController

@synthesize phoneNumber = _phoneNumber;
@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize accessToken = _accessToken;
@synthesize serviceUri = _serviceUri;
@synthesize stcTabs = _stcTabs;

#pragma mark - singletone init

+ (STMAuthController *)authController {
    
    static dispatch_once_t pred = 0;
    __strong static id _authController = nil;
    
    dispatch_once(&pred, ^{
        _authController = [[self alloc] init];
    });
    
    return _authController;
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        NSString *keychainPhoneNumber = [self.keychainItem objectForKey:(__bridge id)kSecAttrLabel];
        [self.phoneNumber isEqualToString:keychainPhoneNumber] ? [self checkAccessToken] : [self.keychainItem resetKeychainItem];
        
    }
    
    return self;
    
}


#pragma mark - variables setters & getters

- (NSString *)phoneNumber {
    
    if (!_phoneNumber) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id phoneNumber = [defaults objectForKey:@"phoneNumber"];
        
        if ([phoneNumber isKindOfClass:[NSString class]]) {
            _phoneNumber = phoneNumber;
            NSLog(@"phoneNumber %@", phoneNumber);
        }
        
    }
    
    return _phoneNumber;
    
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    
    if (phoneNumber != _phoneNumber) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:phoneNumber forKey:@"phoneNumber"];
        [defaults synchronize];

        [self.keychainItem setObject:phoneNumber forKey:(__bridge id)kSecAttrLabel];
        
        _phoneNumber = phoneNumber;
        
    }
    
}

- (NSString *)userName {
    
    if (!_userName) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id userName = [defaults objectForKey:@"userName"];
        
        if ([userName isKindOfClass:[NSString class]]) {
            _userName = userName;
            NSLog(@"userName %@", userName);
        }

    }
    
    return _userName;
    
}

- (void)setUserName:(NSString *)userName {
    
    if (userName != _userName) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userName forKey:@"userName"];
        [defaults synchronize];
        
        _userName = userName;

    }
    
}

- (void)setControllerState:(STMAuthState)controllerState {

    NSLog(@"authControllerState %d", controllerState);
    _controllerState = controllerState;

    if (controllerState == STMAuthRequestRoles) {
        
        [self requestRoles];
        
    } else if (controllerState == STMAuthSuccess) {
        
        NSLog(@"login");
        [self startSession];

    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerStateChanged" object:self];
    
}

- (KeychainItemWrapper *)keychainItem {
    
    if (!_keychainItem) {
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
        id accessible = [_keychainItem objectForKey:(__bridge id)kSecAttrAccessible];
        if (![accessible isEqual: (__bridge id)kSecAttrAccessibleAlways]){
            
            [[STMLogger sharedLogger] saveLogMessageWithText:@"STMAuthController.keychainItem not kSecAttrAccessibleAlways" type:@"error"];
            
            NSString *phoneNumber = [_keychainItem objectForKey:(__bridge id)kSecAttrLabel];
            NSString *serviceUri = [_keychainItem objectForKey:(__bridge id)kSecAttrService];
            NSString *userID = [_keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
            NSString *accessToken = [_keychainItem objectForKey:(__bridge id)(kSecValueData)];
            
            [_keychainItem resetKeychainItem];
            
            [_keychainItem setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
            
            [_keychainItem setObject:phoneNumber forKey:(__bridge id)kSecAttrLabel];
            [_keychainItem setObject:serviceUri forKey:(__bridge id)kSecAttrService];
            [_keychainItem setObject:userID forKey:(__bridge id)kSecAttrAccount];
            [_keychainItem setObject:accessToken forKey:(__bridge id)kSecValueData];

        }

    }
    
    return _keychainItem;
    
}

- (NSString *)serviceUri {
    
    if (!_serviceUri) {
        
        _serviceUri = [self.keychainItem objectForKey:(__bridge id)kSecAttrService];
        
    }
    
    return _serviceUri;
    
}

- (void)setServiceUri:(NSString *)serviceUri {
    
    if (serviceUri != _serviceUri) {
        
        [self.keychainItem setObject:serviceUri forKey:(__bridge id)kSecAttrService];
        NSLog(@"serviceUri %@", serviceUri);
        _serviceUri = serviceUri;
        
    }
    
}

- (NSString *)userID {
    
    if (!_userID) {
        
        _userID = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
        
    }
    
    return _userID;
    
}

- (void)setUserID:(NSString *)userID {
    
    if (userID != _userID) {
        
        [self.keychainItem setObject:userID forKey:(__bridge id)(kSecAttrAccount)];
        NSLog(@"userID %@", userID);
        _userID = userID;
        
    }
    
}

- (NSString *)accessToken {
    
    if (!_accessToken) {
        
        _accessToken = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
        
    }
    
    return _accessToken;
    
}

- (void)setAccessToken:(NSString *)accessToken {
    
    if (accessToken != _accessToken) {
        
        [self.keychainItem setObject:accessToken forKey:(__bridge id)(kSecValueData)];
        NSLog(@"accessToken %@", accessToken);
        _accessToken = accessToken;

        self.lastAuth = [NSDate date];
        self.tokenHash = [STMFunctions MD5FromString:accessToken];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.lastAuth forKey:@"lastAuth"];
        [defaults setObject:self.tokenHash forKey:@"tokenHash"];
        [defaults synchronize];
        
    }
    
}

- (NSString *)tokenHash {
    
    if (!_tokenHash) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *tokenHash = [defaults objectForKey:@"tokenHash"];
        
        if (!tokenHash) {
            
            tokenHash = [STMFunctions MD5FromString:self.accessToken];
            
            if (tokenHash) {
                
                [defaults setObject:tokenHash forKey:@"tokenHash"];
                [defaults synchronize];
                
            } else {
                
                tokenHash = @"tokenHash is empty, should be investigated";
                
            }
            
        }
        
        _tokenHash = tokenHash;
        
    }
    
    return _tokenHash;
    
}

- (NSDate *)lastAuth {
    
    if (!_lastAuth) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _lastAuth = [defaults objectForKey:@"lastAuth"];
        
    }
    
    return _lastAuth;
    
}

- (NSArray *)stcTabs {
    
    if (!_stcTabs) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _stcTabs = [defaults objectForKey:@"stcTabs"];
        
    }
    return _stcTabs;
    
}

- (void)setStcTabs:(NSArray *)stcTabs {
    
    if (![stcTabs isEqual:_stcTabs]) {
        
        _stcTabs = stcTabs;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:stcTabs forKey:@"stcTabs"];
        [defaults synchronize];
        
    }
    
}


#pragma mark - instance methods

- (void)checkAccessToken {

    BOOL checkValue = YES;
    
    if (!self.userID || [self.userID isEqualToString:@""]) {
        NSLog(@"No userID");
        checkValue = NO;
    } else {
        NSLog(@"userID %@", self.userID);
    }
    if (!self.accessToken || [self.accessToken isEqualToString:@""]) {
        NSLog(@"No accessToken");
        checkValue = NO;
    } else {
        NSLog(@"accessToken %@", self.accessToken);
    }

//    BOOL checkValue = ![self.accessToken isEqualToString:@""] && ![self.userID isEqualToString:@""];
    
//    checkValue ? NSLog(@"OK for accessToken && userID") : NSLog(@"NOT OK for accessToken || userID");
    
//    self.controllerState = checkValue ? STMAuthSuccess : STMAuthEnterPhoneNumber;
    self.controllerState = checkValue ? STMAuthRequestRoles : STMAuthEnterPhoneNumber;

}

- (void)logout {
    
    NSLog(@"logout");

    self.controllerState = STMAuthEnterPhoneNumber;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notAuthorized" object:[STMSessionManager sharedManager].currentSession.syncer];
    [[STMSessionManager sharedManager] stopSessionForUID:self.userID];

    self.userID = nil;
    self.accessToken = nil;
    self.stcTabs = nil;
    [self.keychainItem resetKeychainItem];

}

- (void)startSession {
    
    NSArray *trackers = @[@"battery", @"location"];
    
    NSDictionary *startSettings = nil;
    
#ifdef DEBUG
    
    if (GRIMAX) {
        
        startSettings = @{
                          @"restServerURI"            : self.serviceUri,
                          @"dataModelName"            : @"STMDataModel",
                          //                      @"fetchLimit"               : @"50",
                          //                      @"syncInterval"             : @"600",
                          //                      @"uploadLog.type"           : @"",
                          @"requiredAccuracy"         : @"100",
                          @"desiredAccuracy"          : @"10",
                          @"timeFilter"               : @"60",
                          @"maxSpeedThreshold"        : @"60",
                          @"locationTrackerAutoStart" : @YES,
                          @"locationTrackerStartTime": @"8.0",
                          @"locationTrackerFinishTime": @"23.5",
                          @"batteryTrackerAutoStart" : @YES,
                          @"batteryTrackerStartTime": @"8.0",
                          @"batteryTrackerFinishTime": @"22.0",
                          @"enableDebtsEditing"       : @YES,
                          @"enablePartnersEditing"    : @YES,
                          @"http.timeout.foreground"  : @"60",
                          @"jpgQuality"               : @"0.0"
                          };

    }
    
    startSettings = @{
                      @"restServerURI"            : self.serviceUri,
                      @"dataModelName"            : @"STMDataModel",
                      };

#else

    startSettings = @{
                      @"restServerURI"            : self.serviceUri,
                      @"dataModelName"            : @"STMDataModel",
                      };

#endif
    
    if (self.apiURL) {
        
        NSMutableDictionary *tempDictionary = [startSettings mutableCopy];
        [tempDictionary addEntriesFromDictionary:@{@"API.url":self.apiURL}];
        
        startSettings = tempDictionary;
        
    }
    
    [[STMSessionManager sharedManager] startSessionForUID:self.userID authDelegate:self trackers:trackers startSettings:startSettings defaultSettingsFileName:@"settings" documentPrefix:[[NSBundle mainBundle] bundleIdentifier]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionNotAuthorized) name:@"notAuthorized" object:[STMSessionManager sharedManager].currentSession.syncer];
    
}

- (void)sessionNotAuthorized {
    
    [self logout];
    
}

#pragma mark - STMRequestAuthenticatable

- (NSURLRequest *)authenticateRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *resultingRequest = nil;
    
    if (self.accessToken) {
        
        resultingRequest = [request mutableCopy];
        [resultingRequest addValue:self.accessToken forHTTPHeaderField:@"Authorization"];
        [resultingRequest setValue:[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] forHTTPHeaderField:@"DeviceUUID"];


    }
    
    return resultingRequest;
    
}


#pragma mark - send requests

- (BOOL)sendPhoneNumber:(NSString *)phoneNumber {
    
    if ([STMFunctions isCorrectPhoneNumber:phoneNumber]) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.phoneNumber = phoneNumber;
        
        NSString *urlString = [NSString stringWithFormat:@"%@?mobileNumber=%@", AUTH_URL, phoneNumber];
        NSURLRequest *request = [self requestForURL:urlString];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        if (connection) {

            return YES;
            
        } else {

            [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError"
                                                                object:self
                                                              userInfo:@{@"error": @"No connection"}];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            return NO;

        }

    } else {
        return NO;
    }
    
}

- (BOOL)sendSMSCode:(NSString *)SMSCode {
    
    if ([STMFunctions isCorrectSMSCode:SMSCode]) {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        NSString *urlString = [NSString stringWithFormat:@"%@?smsCode=%@&ID=%@", AUTH_URL, SMSCode, self.requestID];
        NSURLRequest *request = [self requestForURL:urlString];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (connection) {
            
            return YES;
            
        } else {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError"
                                                                object:self
                                                              userInfo:@{@"error": NSLocalizedString(@"NO CONNECTION", nil)}];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            self.controllerState = STMAuthEnterPhoneNumber;

            return NO;
            
        }

    } else {
        return NO;
    }
    
}

- (BOOL)requestNewSMSCode {
    
    self.controllerState = STMAuthNewSMSCode;
    return [self sendPhoneNumber:self.phoneNumber];
    
}

- (BOOL)requestRoles {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSURLRequest *request = [self authenticateRequest:[self requestForURL:ROLES_URL]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection) {
        
        return YES;
        
    } else {

        [self connectionErrorWhileRequestingRoles];
        
        return NO;
        
    }

    return YES;
}

- (NSURLRequest *)requestForURL:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:[[UIDevice currentDevice].identifierForVendor UUIDString] forHTTPHeaderField:@"DeviceUUID"];
    request.timeoutInterval = TIMEOUT;

    return request;
    
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

#ifdef DEBUG
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    NSLog(@"%@", errorMessage);
#endif
    
    if (self.controllerState == STMAuthRequestRoles) {

        [self connectionErrorWhileRequestingRoles];
        
    } else {
        
        self.controllerState = STMAuthEnterPhoneNumber;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError" object:self userInfo:@{@"error": error.localizedDescription}];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];

    switch (statusCode) {
        case 401:
            [self gotUnauthorizedStatus];
            break;
            
        default:
            self.responseData = [NSMutableData data];
            break;
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self parseResponse:self.responseData fromConnection:connection];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.responseData = nil;
    
}

- (void)gotUnauthorizedStatus {
    
    if (self.controllerState == STMAuthRequestRoles) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                            message:NSLocalizedString(@"U R NOT AUTH", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
    [self logout];
    
}

- (void)connectionErrorWhileRequestingRoles {
    
    if (self.stcTabs) {
        
        self.controllerState = STMAuthSuccess;
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                            message:NSLocalizedString(@"CAN NOT GET ROLES", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                                  otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        alertView.tag = 1;
        [alertView show];
        
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
            
        case 1:
            switch (buttonIndex) {
                    
                case 0:
                    [self logout];
                    break;
                    
                case 1:
                    [self requestRoles];
                    break;
                    
                default:
                    break;
                    
            }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - parse response

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    
    if (responseData) {
        
        NSError *error;
        id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
//        NSLog(@"responseData %@", responseData);
//        NSLog(@"responseJSON %@", responseJSON);
        
        if ([responseJSON isKindOfClass:[NSDictionary class]]) {
            
            [self processingResponseJSON:responseJSON];
            
        } else {
            
            [self processingResponseJSONError];
            
        }

    }
    
}

- (void)processingResponseJSON:(NSDictionary *)responseJSON {
    
    switch (self.controllerState) {
            
        case STMAuthEnterPhoneNumber: {
            
            self.requestID = responseJSON[@"ID"];
            self.controllerState = STMAuthEnterSMSCode;
            
            break;
            
        }
            
        case STMAuthEnterSMSCode: {
            
            self.serviceUri = responseJSON[@"redirectUri"];
            
            //#warning Switch comment line when server give correct apiURL
            self.apiURL = responseJSON[@"apiUrl"];
            //self.apiURL = [self.serviceUri stringByDeletingLastPathComponent];
            
            self.userID = responseJSON[@"ID"];
            self.userName = responseJSON[@"name"];
            self.accessToken = responseJSON[@"accessToken"];
            
            self.controllerState = STMAuthRequestRoles;
            
            break;
            
        }
            
        case STMAuthNewSMSCode: {
            
            self.requestID = responseJSON[@"ID"];
            self.controllerState = STMAuthEnterSMSCode;
            
            break;
            
        }
            
        case STMAuthRequestRoles: {
            
            self.stcTabs = responseJSON[@"roles"][@"stcTabs"];
            self.controllerState = STMAuthSuccess;
            
            break;
            
        }
            
        case STMAuthSuccess: {
            break;
        }
            
        default: {
            break;
        }
            
    }

}

- (void)processingResponseJSONError {
    
    if (self.controllerState == STMAuthRequestRoles) {

        [self connectionErrorWhileRequestingRoles];
        
    } else {
    
        NSString *errorString = NSLocalizedString(@"RESPONSE IS NOT A DICTIONARY", nil);
        
        if (self.controllerState == STMAuthEnterPhoneNumber) {
            
            errorString = NSLocalizedString(@"WRONG PHONE NUMBER", nil);
            self.controllerState = STMAuthEnterPhoneNumber;
            
        } else if (self.controllerState == STMAuthEnterSMSCode) {
            
            errorString = NSLocalizedString(@"WRONG SMS CODE", nil);
            self.controllerState = STMAuthEnterSMSCode;
            
//        } else if (self.controllerState == STMAuthRequestRoles) {
//            
//            errorString = [NSLocalizedString(@"ROLES REQUEST ERROR", nil) stringByAppendingString:errorString];
//            self.controllerState = STMAuthEnterPhoneNumber;
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError" object:self userInfo:@{@"error": errorString}];

    }
    
}


@end
