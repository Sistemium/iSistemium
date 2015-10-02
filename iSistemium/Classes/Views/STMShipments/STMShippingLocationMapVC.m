//
//  STMLocationMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingLocationMapVC.h"

#import "STMSessionManager.h"
#import "STMSession.h"

#import "STMObjectsController.h"
#import "STMLocationController.h"

#import "STMFunctions.h"
#import "STMMapAnnotation.h"
#import "STMRouteMapVC.h"

#import "STMUI.h"


typedef NS_ENUM(NSInteger, STMShippingLocationState) {
    STMShippingLocationHaveLocation,
    STMShippingLocationNoLocation,
    STMShippingLocationConfirm,
    STMShippingLocationConfirmByUser,
    STMShippingLocationSet
};


@interface STMShippingLocationMapVC () <MKMapViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (nonatomic, strong) STMShippingLocation *shippingLocation;
@property (nonatomic, strong) STMLocation *location;

@property (nonatomic, weak) STMSession *session;

@property (nonatomic) STMShippingLocationState state;

@property (nonatomic, strong) STMMapAnnotation *locationPin;
@property (nonatomic, strong) STMMapAnnotation *confirmingPin;
@property (nonatomic, strong) CLLocation *confirmingLocation;
@property (nonatomic, strong) MKCircle *accuracyCircle;

@property (nonatomic) BOOL mapWasCentered;
@property (nonatomic) BOOL isAccuracySufficient;

@property (nonatomic) CGFloat permanentLocationRequiredAccuracy;
@property (nonatomic) CGFloat currentAccuracy;

@property (nonatomic, strong) STMSpinnerView *spinner;

@property (nonatomic, strong) STMMapAnnotation *userPin;
@property (nonatomic, strong) UISearchBar *searchBar;


@end


@implementation STMShippingLocationMapVC

#pragma mark - setters & getters

- (STMShippingLocation *)shippingLocation {
    return self.point.shippingLocation;
}

- (STMLocation *)location {
    return self.shippingLocation.location;
}

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
    
    if (_state == STMShippingLocationNoLocation) {
        
        [self showSearchBar];
        
    } else if (_state == STMShippingLocationSet) {
        
        [self hideSearchBar];
        
    }
    
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
        case STMShippingLocationConfirm:
        case STMShippingLocationConfirmByUser: {
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
    
    [self updateNavBar];

    if (self.location) {

        
    } else {

        
    }
    
}

- (void)centeringMapOnSettedLocation {
        
    if (self.location) {
    
        CLLocation *location = [STMLocationController locationFromLocationObject:self.location];

        self.locationPin = [STMMapAnnotation createAnnotationForCLLocation:location
                                                                 withTitle:[STMFunctions shortCompanyName:self.point.shortName]
                                                               andSubtitle:self.point.address];
        
        [self.mapView addAnnotation:self.locationPin];
        
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
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, distance, distance);
        
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
    }

}

- (void)centeringMapOnUserLocation {
    
    CLLocation *userLocation = self.mapView.userLocation.location;
    
    if (userLocation) {
        
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        //            [self drawAccuracyCircle];
        
    } else {
        
        CLLocationDistance distance = 1000;
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(0, 0);
        
        CLLocation *lastLocation = self.session.locationTracker.lastLocation;
        
        if (lastLocation) {
            
            locationCoordinate = lastLocation.coordinate;
            
        }
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, distance, distance);
        
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
        
    }

}

- (void)centeringMapOnConfirm {
    
//    self.confirmingLocation = self.mapView.userLocation.location;
    self.confirmingPin = [STMMapAnnotation createAnnotationForCLLocation:self.confirmingLocation];
    [self.mapView addAnnotation:self.confirmingPin];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];

    CLLocationDistance distance = 100;
//    CLLocationCoordinate2D locationCoordinate = self.mapView.userLocation.location.coordinate;
    CLLocationCoordinate2D locationCoordinate = self.confirmingLocation.coordinate;
    
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

    [self.spinner removeFromSuperview];
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
            
        case STMShippingLocationConfirm:
        case STMShippingLocationConfirmByUser: {
            title = NSLocalizedString(@"CONFIRM SET LOCATION", nil);
            break;
        }
        case STMShippingLocationSet: {
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
            self.confirmingLocation = self.mapView.userLocation.location;
            self.state = STMShippingLocationConfirm;
            break;
        }
        case STMShippingLocationConfirm:
        case STMShippingLocationConfirmByUser: {
            [self setShippingLocation];
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
    
    if (self.state == STMShippingLocationConfirm) {
        [self.point updateShippingLocationWithConfirmedLocation:self.confirmingLocation];
    } else if (self.state == STMShippingLocationConfirmByUser) {
        [self.point updateShippingLocationWithUserLocation:self.confirmingLocation];
    }
    

    self.state = STMShippingLocationSet;

    self.confirmingLocation = nil;
    
    [self.session.document saveDocument:^(BOOL success) {
        self.state = STMShippingLocationHaveLocation;
    }];
    
    if (IPHONE) {

        [self.navigationController popViewControllerAnimated:YES];
        
    } else {

        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];

    }
    
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
            case STMShippingLocationConfirm:
            case STMShippingLocationConfirmByUser: {
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
        
        if ([myAnnotation isEqual:self.userPin]) {
            
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            CGSize size = infoButton.frame.size;
            infoButton.frame = CGRectMake(0, 0, size.width + 10, size.height);
            infoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
            
            annotationView.rightCalloutAccessoryView = infoButton;

        }
        
        annotationView.canShowCallout = YES;
        
        return annotationView;

    } else {

        return nil;

    }
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    CLLocationCoordinate2D coordinate = [(STMMapAnnotation *)view.annotation coordinate];
    
    [self.mapView removeAnnotation:self.userPin];
    self.userPin = nil;
    
    self.confirmingLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    self.state = STMShippingLocationConfirmByUser;

}


#pragma mark - navBar

- (void)updateNavBar {

    if (self.splitVC) {
        
        STMBarButtonItem *closeButton = [[STMBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil)
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(closeButtonPressed)];
        self.navigationItem.leftBarButtonItem = closeButton;
        
    }

    self.navigationItem.rightBarButtonItem = nil;

    if (self.mapView.userLocation.location) {
        
        if (self.shippingLocation) {
            
            STMBarButtonItem *waypointButton = [[STMBarButtonItem alloc] initWithCustomView:[self waypointView]];
            self.navigationItem.rightBarButtonItem = waypointButton;

        }
        
    }
    
}

- (UIView *)waypointView {
    
    CGFloat imageSize = 22;
    CGFloat imagePadding = 0;
    
    UIImage *image = [[UIImage imageNamed:@"single_waypoint_map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(imagePadding, imagePadding, imageSize, imageSize);
    imageView.tintColor = (self.state == STMShippingLocationHaveLocation) ? ACTIVE_BLUE_COLOR : [UIColor lightGrayColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageSize + imagePadding * 2, imageSize + imagePadding * 2)];
    [button addTarget:self action:@selector(waypointButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:imageView];
    
    return button;
    
}

- (void)waypointButtonPressed {
    if (self.state == STMShippingLocationHaveLocation) [self performSegueWithIdentifier:@"showRoute" sender:self];
}

- (void)closeButtonPressed {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showRoute"] &&
        [segue.destinationViewController isKindOfClass:[STMRouteMapVC class]]) {
        
        STMRouteMapVC *mapVC = (STMRouteMapVC *)segue.destinationViewController;
        
        mapVC.shippingLocation = self.shippingLocation;        
        mapVC.destinationPointName = self.point.name;
        mapVC.destinationPointAddress = self.point.address;
        
    }
    
}


#pragma mark - long press gesture

- (void)addLongPressGesture {
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    self.mapView.userInteractionEnabled = YES;
    [self.mapView addGestureRecognizer:longPress];
    
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
    
        CGPoint point = [longPress locationInView:longPress.view];
        
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:longPress.view];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self addUserPinAtLocation:location];
        
    }

}

- (void)addUserPinAtLocation:(CLLocation *)location {
    
    if (self.userPin) [self.mapView removeAnnotation:self.userPin];

    STMMapAnnotation *pin = [STMMapAnnotation createAnnotationForCLLocation:location
                                                                  withTitle:NSLocalizedString(@"ADD POSITION?", nil)
                                                                andSubtitle:nil];
    self.userPin = pin;
    
    [self.mapView addAnnotation:self.userPin];
    
    [self.mapView selectAnnotation:pin animated:YES];

}


#pragma mark - searchBar

- (void)showSearchBar {

    if (!self.searchBar) {
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT);
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:frame];
        self.searchBar.text = self.point.address;
        self.searchBar.delegate = self;
        
        [self.view addSubview:self.searchBar];
        
    }
    
}

- (void)hideSearchBar {
    
    [self.searchBar removeFromSuperview];
    self.searchBar = nil;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    __block STMSpinnerView *spinner = [STMSpinnerView spinnerViewWithFrame:self.view.bounds];
    [self.view addSubview:spinner];

    [[[CLGeocoder alloc] init] geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        
        [spinner removeFromSuperview];
        
        if (!error) {
            
            [self.searchBar resignFirstResponder];
            
            CLPlacemark *placemark = placemarks.firstObject;
            [self addUserPinAtLocation:placemark.location];
            [self.mapView showAnnotations:@[self.userPin] animated:YES];
            
        } else {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                                message:NSLocalizedString(@"ADDRESS GEOCODING FAILED", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                
            }];
            
        }
        
    }];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    return YES;
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    return YES;
    
}


#pragma mark - view lifecycle

- (void)initState {
    
    self.state = (self.location) ? STMShippingLocationHaveLocation : STMShippingLocationNoLocation;
    
}

- (void)customInit {
    
    if (self.point) {
        
        [self initState];
        [self setupLocationButton];
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = YES;
        [self centeringMap];
        [self addLongPressGesture];

    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self updateNavBar];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self centeringMap];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self isMovingFromParentViewController]) {
        [self flushMapView];
    }
    
    [super viewWillDisappear:animated];
    
}

- (void)flushMapView {
    
    switch (self.mapView.mapType) {
        case MKMapTypeHybrid:
        {
            self.mapView.mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            self.mapView.mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
        
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
}

- (void)didReceiveMemoryWarning {
    
    if ([STMFunctions shouldHandleMemoryWarningFromVC:self]) {
        
        [self flushMapView];
        [STMFunctions nilifyViewForVC:self];

    }

    [super didReceiveMemoryWarning];

}


@end
