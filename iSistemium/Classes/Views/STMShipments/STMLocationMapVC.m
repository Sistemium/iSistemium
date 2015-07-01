//
//  STMLocationMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMLocationMapVC.h"
#import "STMFunctions.h"
#import "STMSessionManager.h"
#import "STMSession.h"
#import "STMMapAnnotation.h"


@interface STMLocationMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (nonatomic, weak) STMSession *session;
@property (nonatomic, strong) MKCircle *accuracyCircle;

@property (nonatomic) BOOL mapWasCentered;


@end


@implementation STMLocationMapVC

- (STMSession *)session {
    
    if (!_session) {
        _session = [STMSessionManager sharedManager].currentSession;
    }
    return _session;
    
}

- (void)centeringMap {

    if (self.location) {
        
        [self.mapView addAnnotation:[STMMapAnnotation createAnnotationForLocation:self.location]];
        
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(self.location.latitude.doubleValue, self.location.longitude.doubleValue);
        CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude];
        
        CLLocationDistance distance = 10000;
        
        CLLocation *userLocation = self.mapView.userLocation.location;
        
        if (userLocation) {
            
            distance = [location distanceFromLocation:userLocation] * 2;
            
        } else {
            
            CLLocation *lastLocation = self.session.locationTracker.lastLocation;
            
            if (lastLocation) {
                
                distance = [location distanceFromLocation:lastLocation] * 2;
                
            }
            
        }
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, distance, distance);
        
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
    } else {
        
        CLLocation *userLocation = self.mapView.userLocation.location;
        
        if (userLocation) {
            
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
            [self drawAccuracyCircle];

        } else {
            
            CLLocationDistance distance = 1000;
            CLLocationCoordinate2D locationCoordinate;

            CLLocation *lastLocation = self.session.locationTracker.lastLocation;
            
            if (lastLocation) {
                
                locationCoordinate = lastLocation.coordinate;
                
            }

            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, distance, distance);
            
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];

        }
        
    }
    
}

- (void)drawAccuracyCircle {
    
// MKMapView draw accuracy circle around user location at least if MKUserTrackingModeFollow in on, other modes was not checked
    
//    [self.mapView removeOverlay:self.accuracyCircle];
//    
//    CLLocation *userLocation = self.mapView.userLocation.location;
//    self.accuracyCircle = [MKCircle circleWithCenterCoordinate:userLocation.coordinate radius:userLocation.horizontalAccuracy];
//    
//    [self.mapView addOverlay:self.accuracyCircle];

}

- (void)setupLocationButton {
    
    self.locationButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    self.locationButton.layer.cornerRadius = 5;
    self.locationButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.locationButton.layer.borderWidth = 1;
    
    NSString *title = (self.location) ? NSLocalizedString(@"RESET LOCATION", nil) : NSLocalizedString(@"SET LOCATION", nil);
    
    if (!self.session.locationTracker.isAccuracySufficient) {
        
        title = NSLocalizedString(@"ACCURACY IS NOT SUFFICIENT", nil);
        self.locationButton.enabled = NO;
        
    } else {
        
        self.locationButton.enabled = YES;
        
    }
    
    [self.locationButton setTitle:title forState:UIControlStateNormal];
    
}

- (void)updateLocationButton {
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!self.mapWasCentered) {
        
        [self centeringMap];
        self.mapWasCentered = YES;

    } else {
        
        [self drawAccuracyCircle];
        
    }
    
    [self updateLocationButton];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if (overlay == self.accuracyCircle) {
        
        MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:self.accuracyCircle];
        circleView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.1];
        
        return circleView;

    } else {
        return nil;
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self setupLocationButton];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self centeringMap];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self centeringMap];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
