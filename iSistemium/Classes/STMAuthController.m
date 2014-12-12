//
//  STAuthController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAuthController.h"
#import "STMFunctions.h"
#import <Security/Security.h>
#import <KeychainItemWrapper/KeychainItemWrapper.h>
#import "STMSessionManager.h"

#define AUTH_URL @"https://sistemium.com/auth.php"

@interface STMAuthController() <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *serviceUri;
@property (nonatomic, strong) KeychainItemWrapper *keychainItem;

@end


@implementation STMAuthController

@synthesize phoneNumber = _phoneNumber;
@synthesize userID = _userID;
@synthesize userName = _userName;
@synthesize accessToken = _accessToken;
@synthesize serviceUri = _serviceUri;

#pragma mark - singletone init

+ (STMAuthController *)authController {
    
    static dispatch_once_t pred = 0;
    __strong static id _authController = nil;
    
    dispatch_once(&pred, ^{
        _authController = [[self alloc] init];
    });
    
    return _authController;
    
}

- (id)init {
    
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
    
    if (controllerState == STMAuthSuccess) {
        NSLog(@"login");
        [self startSession];
    }
    
    NSLog(@"authControllerState %d", controllerState);
    
    _controllerState = controllerState;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerStateChanged" object:self];
    
}

- (KeychainItemWrapper *)keychainItem {
    
    if (!_keychainItem) {
        
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
        
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

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDate date] forKey:@"lastAuth"];
        [defaults setObject:[STMFunctions MD5FromString:accessToken] forKey:@"tokenHash"];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"clientDataWaitingForSync"];
        [defaults synchronize];
        
    }
    
}

- (NSString *)tokenHash {
    
    if (!_tokenHash) {
        
        NSString *tokenHash = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokenHash"];
        
        if (!tokenHash) {
            
            tokenHash = [STMFunctions MD5FromString:self.accessToken];
            
            if (tokenHash) {
                
                [[NSUserDefaults standardUserDefaults] setObject:tokenHash forKey:@"tokenHash"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            } else {
                
                tokenHash = @"tokenHash is empty, should be investigated";
                
            }
            
        }
        
        _tokenHash = tokenHash;
        
    }
    
    return _tokenHash;
    
}

#pragma mark - instance methods

- (void)checkAccessToken {

    if (self.userID) {
        NSLog(@"userID %@", self.userID);
    } else {
        NSLog(@"No userID");
    }
    if (self.accessToken) {
//        NSLog(@"accessToken %@", self.accessToken);
        NSLog(@"accessToken ok");
    } else {
        NSLog(@"No accessToken");
    }

    BOOL checkValue = ![self.accessToken isEqualToString:@""] && ![self.userID isEqualToString:@""];
    
//    checkValue ? NSLog(@"OK for accessToken && userID") : NSLog(@"NOT OK for accessToken || userID");
    
    self.controllerState = checkValue ? STMAuthSuccess : STMAuthEnterPhoneNumber;

}

- (void)logout {
    
    NSLog(@"logout");

    self.controllerState = STMAuthEnterPhoneNumber;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notAuthorized" object:[STMSessionManager sharedManager].currentSession.syncer];
    [[STMSessionManager sharedManager] stopSessionForUID:self.userID];

    self.userID = nil;
    self.accessToken = nil;
    [self.keychainItem resetKeychainItem];

}

- (void)startSession {
    
    NSArray *trackers = [NSArray arrayWithObjects:@"battery", @"location", nil];
    
    NSDictionary *startSettings = nil;
    
#ifdef DEBUG

    startSettings = @{
                      @"restServerURI"            : self.serviceUri,
                      @"dataModelName"            : @"STMDataModel",
//                      @"fetchLimit"               : @"50",
//                      @"syncInterval"             : @"600",
                      @"requiredAccuracy"         : @"100",
                      @"desiredAccuracy"          : @"10",
                      @"timeFilter"               : @"60",
                      @"maxSpeedThreshold"        : @"60",
                      @"locationTrackerAutoStart" : [NSNumber numberWithBool:YES],
                      @"enableDebtsEditing"       : [NSNumber numberWithBool:YES],
                      @"http.timeout.foreground"  : @"15"
                      };

#else

    startSettings = @{
                      @"restServerURI"            : self.serviceUri,
                      @"dataModelName"            : @"STMDataModel",
                      };

#endif
    
    [[STMSessionManager sharedManager] startSessionForUID:self.userID authDelegate:self trackers:trackers startSettings:startSettings defaultSettingsFileName:@"settings" documentPrefix:[[NSBundle mainBundle] bundleIdentifier]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionNotAuthorized) name:@"notAuthorized" object:[STMSessionManager sharedManager].currentSession.syncer];
    
}

- (void)sessionNotAuthorized {
    
    [self logout];
    
}

#pragma mark - STMRequestAuthenticatable

- (NSURLRequest *) authenticateRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *resultingRequest = nil;
    
    if (self.accessToken) {
        resultingRequest = [request mutableCopy];
        [resultingRequest addValue:self.accessToken forHTTPHeaderField:@"Authorization"];
    }
    
    return resultingRequest;
    
}


#pragma mark - send requests

- (void)sendPhoneNumber:(NSString *)phoneNumber {
    
    if ([STMFunctions isCorrectPhoneNumber:phoneNumber]) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        self.phoneNumber = phoneNumber;
        
        NSString *urlString = [NSString stringWithFormat:@"%@?mobileNumber=%@", AUTH_URL, phoneNumber];
        NSURLRequest *request = [self requestForURL:urlString];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

        if (!connection) {

            [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError" object:self userInfo:[NSDictionary dictionaryWithObject:@"No connection" forKey:@"error"]];

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        }

    }
    
}

- (void)sendSMSCode:(NSString *)SMSCode {
    
    if ([STMFunctions isCorrectSMSCode:SMSCode]) {

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        NSString *urlString = [NSString stringWithFormat:@"%@?smsCode=%@&ID=%@", AUTH_URL, SMSCode, self.requestID];
        NSURLRequest *request = [self requestForURL:urlString];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (!connection) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError" object:self userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"NO CONNECTION", nil) forKey:@"error"]];

            self.controllerState = STMAuthEnterPhoneNumber;
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        }

    }
    
}

- (void)requestNewSMSCode {
    
    self.controllerState = STMAuthNewSMSCode;
    [self sendPhoneNumber:self.phoneNumber];
    
}

- (NSURLRequest *)requestForURL:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];

    return request;
    
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

#ifdef DEBUG
    NSString *errorMessage = [NSString stringWithFormat:@"connection did fail with error: %@", error];
    NSLog(@"%@", errorMessage);
#endif
    
    self.controllerState = STMAuthEnterPhoneNumber;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError" object:self userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self parseResponse:self.responseData fromConnection:connection];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}


#pragma mark - parse response

- (void)parseResponse:(NSData *)responseData fromConnection:(NSURLConnection *)connection {
    
    NSError *error;
    id responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    
//    NSLog(@"responseData %@", responseData);
//    NSLog(@"responseJSON %@", responseJSON);

    if ([responseJSON isKindOfClass:[NSDictionary class]]) {
        
        if (self.controllerState == STMAuthEnterPhoneNumber || self.controllerState == STMAuthNewSMSCode) {
            
            self.requestID = [responseJSON objectForKey:@"ID"];
            self.controllerState = STMAuthEnterSMSCode;

        } else if (self.controllerState == STMAuthEnterSMSCode) {
            
            self.serviceUri = [responseJSON objectForKey:@"redirectUri"];
            self.userID = [responseJSON objectForKey:@"ID"];
            self.userName = [responseJSON objectForKey:@"name"];
            self.accessToken = [responseJSON objectForKey:@"accessToken"];
            self.controllerState = STMAuthSuccess;
            
        }
        
    } else {
        
        NSString *error;
        
        if (self.controllerState == STMAuthEnterPhoneNumber) {

            error = NSLocalizedString(@"WRONG PHONE NUMBER", nil);
            self.controllerState = STMAuthEnterPhoneNumber;
            
        } else if (self.controllerState == STMAuthEnterSMSCode) {
            
            error = NSLocalizedString(@"WRONG SMS CODE", nil);
            self.controllerState = STMAuthEnterSMSCode;

        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"authControllerError" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
        
    }
    
}



@end
