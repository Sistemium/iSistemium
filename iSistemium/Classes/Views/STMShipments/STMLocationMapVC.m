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

typedef NS_ENUM(NSInteger, STMShippingLocationState) {
    STMShippingLocationHaveLocation,
    STMShippingLocationNoLocation,
    STMShippingLocationConfirm,
    STMShippingLocationSet
};

@interface STMLocationMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (nonatomic, weak) STMSession *session;
@property (nonatomic, strong) MKCircle *accuracyCircle;

@property (nonatomic) BOOL mapWasCentered;

@property (nonatomic) CGFloat permanentLocationRequiredAccuracy;
@property (nonatomic) CGFloat currentAccuracy;
@property (nonatomic) BOOL isAccuracySufficient;

@property (nonatomic) STMShippingLocationState state;

@property (nonatomic, strong) STMMapAnnotation *locationPin;
@property (nonatomic, strong) STMMapAnnotation *confirmingPin;

@end


@implementation STMLocationMapVC

#pragma mark - setters & getters

- (STMSession *)session {
    
    if (!_session) {
        _session = [STMSessionManager sharedManager].currentSession;
    }
    return _session;
    
}

- (CGFloat)permanentLocationRequiredAccuracy {
    
    if (!_permanentLocationRequiredAccuracy) {
        
        NSDictionary *settings = [self.session.settingsController currentSettingsForGroup:@"location"];
        _permanentLocationRequiredAccuracy = [settings[@"permanentLocationRequiredAccuracy"] doubleValue];
        
    }
    return _permanentLocationRequiredAccuracy;
    
}

- (void)setCurrentAccuracy:(CGFloat)currentAccuracy {
    
    if (_currentAccuracy != currentAccuracy) {
        
        _currentAccuracy = currentAccuracy;
        [self updateLocationButton];
        
    }
    
}

- (BOOL)isAccuracySufficient {
    return (self.currentAccuracy != 0) ? (self.currentAccuracy <= self.permanentLocationRequiredAccuracy) : NO;
}

- (void)setState:(STMShippingLocationState)state {
    
    _state = (state != _state) ? state : _state;

    [self updateLocationButton];
    [self centeringMap];
    
}


#pragma mark - instance's methods

- (void)centeringMap {
    
    [self.mapView removeAnnotation:self.locationPin];
    [self.mapView removeAnnotation:self.confirmingPin];

    switch (self.state) {
        case STMShippingLocationHaveLocation: {
            [self centeringMapOnSettedLocation];
            break;
        }
        case STMShippingLocationNoLocation: {
            [self centeringMapOnUserLocation];
            break;
        }
        case STMShippingLocationConfirm: {
            [self centeringMapOnConfirm];
            break;
        }
        case STMShippingLocationSet: {
            
            break;
        }
        default: {
            break;
        }
    }
    
    if (self.location) {

        
    } else {

        
    }
    
}

- (void)centeringMapOnSettedLocation {
    
    self.locationPin = [STMMapAnnotation createAnnotationForLocation:self.location];
    [self.mapView addAnnotation:self.locationPin];
    
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

}

- (void)centeringMapOnUserLocation {
    
    CLLocation *userLocation = self.mapView.userLocation.location;
    
    if (userLocation) {
        
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        //            [self drawAccuracyCircle];
        
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

- (void)centeringMapOnConfirm {
    
    STMMapAnnotation *confirmingPin = [STMMapAnnotation createAnnotationForCLLocation:self.mapView.userLocation.location];
    [self.mapView addAnnotation:confirmingPin];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];

    CLLocationDistance distance = 100;
    CLLocationCoordinate2D locationCoordinate = self.mapView.userLocation.location.coordinate;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, distance, distance);
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

}

//- (void)drawAccuracyCircle {
//
// MKMapView draw accuracy circle around user location at least if MKUserTrackingModeFollow in on, other modes was not checked
//    
//    [self.mapView removeOverlay:self.accuracyCircle];
//    
//    CLLocation *userLocation = self.mapView.userLocation.location;
//    self.accuracyCircle = [MKCircle circleWithCenterCoordinate:userLocation.coordinate radius:userLocation.horizontalAccuracy];
//    
//    [self.mapView addOverlay:self.accuracyCircle];
//
//}

- (void)setupLocationButton {
    
    self.locationButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    self.locationButton.layer.cornerRadius = 5;
    self.locationButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.locationButton.layer.borderWidth = 1;
    
    [self updateLocationButton];
    
}

- (void)updateLocationButton {
    
    NSString *title = nil;

    self.locationButton.enabled = YES;
        
    switch (self.state) {
            
        case STMShippingLocationHaveLocation: {
            title = NSLocalizedString(@"RESET LOCATION", nil);
            break;
        }
            
        case STMShippingLocationNoLocation: {
            title = NSLocalizedString(@"SET LOCATION", nil);
            
            if (!self.isAccuracySufficient) {

                title = NSLocalizedString(@"ACCURACY IS NOT SUFFICIENT", nil);
                self.locationButton.enabled = NO;

            }
            break;
        }
            
        case STMShippingLocationConfirm: {
            title = NSLocalizedString(@"CONFIRM SET LOCATION", nil);
            break;
        }
            
        case STMShippingLocationSet: {
            [self setShippingLocation];
            break;
        }
            
        default: {
            break;
        }
            
    }
        
    [self.locationButton setTitle:title forState:UIControlStateNormal];

}

- (IBAction)locationButtonPressed:(id)sender {
    
    switch (self.state) {
        case STMShippingLocationHaveLocation: {
            self.state = STMShippingLocationNoLocation;
            break;
        }
        case STMShippingLocationNoLocation: {
            self.state = STMShippingLocationConfirm;
            break;
        }
        case STMShippingLocationConfirm: {
            self.state = STMShippingLocationSet;
            break;
        }
        case STMShippingLocationSet: {
            
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)setShippingLocation {
    
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!self.mapWasCentered) {
        
        [self centeringMap];
        self.mapWasCentered = YES;

    } else {
        
//        [self drawAccuracyCircle];
        self.currentAccuracy = userLocation.location.horizontalAccuracy;
        
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[STMMapAnnotation class]]) {
        
        static NSString *identifier = @"STMMapAnnotation";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        STMMapAnnotation *myAnnotation = (STMMapAnnotation *)annotation;
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        switch (self.state) {
            case STMShippingLocationHaveLocation: {
                annotationView.pinColor = MKPinAnnotationColorRed;
                break;
            }
            case STMShippingLocationNoLocation: {
                
                break;
            }
            case STMShippingLocationConfirm: {
                annotationView.pinColor = MKPinAnnotationColorPurple;
                break;
            }
            case STMShippingLocationSet: {
                
                break;
            }
            default: {
                annotationView.pinColor = MKPinAnnotationColorGreen;
                break;
            }
        }
                
        return annotationView;

    } else {

        return nil;

    }
    
}


#pragma mark - view lifecycle

- (void)initState {
    
    self.state = (self.location) ? STMShippingLocationHaveLocation : STMShippingLocationNoLocation;
    
}

- (void)customInit {
    
    [self initState];
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
