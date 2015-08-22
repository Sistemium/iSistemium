//
//  STMRouteMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRouteMapVC.h"
#import "STMMapAnnotation.h"
#import "STMUI.h"
#import "STMLocationController.h"

#import <AVFoundation/AVFoundation.h>


#define DISTANCE_SCALE 1.5
#define EDGE_INSET 50


@interface STMRouteMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routeInfoLabel;

@property (nonatomic, strong) CLLocation *destinationPoint;

@property (nonatomic, strong) STMMapAnnotation *startPin;
@property (nonatomic, strong) STMMapAnnotation *destinationPin;

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic) NSUInteger selectedRouteNumber;

@property (nonatomic, strong) STMSpinnerView *spinner;


@end


@implementation STMRouteMapVC

- (void)setupMapView {

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    self.destinationPoint = (self.shippingLocation.location) ? [STMLocationController locationFromLocationObject:self.shippingLocation.location] : self.destinationPoint;
    
    if (self.startPoint && self.destinationPoint) {
    
        self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint
                                                              withTitle:NSLocalizedString(@"CURRENT GEOPOSITION", nil)
                                                            andSubtitle:nil];
        
        NSString *title = (self.shippingLocation.name) ? self.shippingLocation.name : self.destinationPointName;
        NSString *subtitle = (self.shippingLocation.address) ? self.shippingLocation.address : self.destinationPointAddress;
        
        self.destinationPin = [STMMapAnnotation createAnnotationForCLLocation:self.destinationPoint
                                                                    withTitle:[STMFunctions shortCompanyName:title]
                                                                  andSubtitle:subtitle];
        [self.mapView addAnnotation:self.startPin];
        [self.mapView addAnnotation:self.destinationPin];

        CLLocationDegrees midLatitude = (self.startPoint.coordinate.latitude + self.destinationPoint.coordinate.latitude) / 2;
        CLLocationDegrees midLongitude = (self.startPoint.coordinate.longitude + self.destinationPoint.coordinate.longitude) / 2;
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(midLatitude, midLongitude);
        CLLocationDistance distance = [self.startPoint distanceFromLocation:self.destinationPoint] * DISTANCE_SCALE;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate, distance, distance);
        
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
        [self calcRoute];

    }
    
}

- (void)updateMapView {
 
    if (self.routes) {
        
        MKRoute *currentRoute = self.routes[self.selectedRouteNumber];
        
        [self.mapView setVisibleMapRect:currentRoute.polyline.boundingMapRect
                            edgePadding:UIEdgeInsetsMake(EDGE_INSET, EDGE_INSET, EDGE_INSET, EDGE_INSET)
                               animated:YES];

    }
    
}

- (void)calcRoute {
    
    self.routeInfoLabel.title = NSLocalizedString(@"CALC ROUTES", nil);
    self.routeInfoLabel.enabled = NO;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKPlacemark *start = [[MKPlacemark alloc] initWithCoordinate:self.startPoint.coordinate addressDictionary:nil];
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:self.destinationPoint.coordinate addressDictionary:nil];
    
    request.source = [[MKMapItem alloc] initWithPlacemark:start];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destination];
    
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
         if (!error) {
             
             self.routes = response.routes;
             self.selectedRouteNumber = 0;
             [self updateRoutesOverlays];
             
         } else {
        
             [self.spinner removeFromSuperview];
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                             message:error.localizedDescription
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                   otherButtonTitles:nil];
             [alert show];
             
         }

        [self updateToolbar];

     }];

}

- (void)updateRoutesOverlays {
    
    [self.spinner removeFromSuperview];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for (MKRoute *route in self.routes) {
        
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
//        for (MKRouteStep *step in route.steps) {
//            
//            NSLog(@"%@", step.instructions);
//            
//            AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
//            synthesizer.delegate = self;
//            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:step.instructions];
//            
//            [synthesizer speakUtterance:utterance];
//            
//        }
        
    }
    
}

- (void)updateToolbar {
    
    [self removeAllSwipes];
    
    if (self.routes.count > 0) {
        
        MKRoute *route = self.routes[self.selectedRouteNumber];
        
//        NSLog(@"Route name: %@", route.name);
        
        NSUInteger distanceInKm = (NSUInteger)floor(route.distance / 1000);
        NSUInteger meters = (NSUInteger)(route.distance - 1000 * distanceInKm);

        NSString *distanceString;
        if (distanceInKm > 0) {
            distanceString = [NSString stringWithFormat:@"%@%@ %@%@", @(distanceInKm), NSLocalizedString(@"DISTANCE_KM", nil), @(meters), NSLocalizedString(@"DISTANCE_M", nil)];
        } else {
            distanceString = [NSString stringWithFormat:@"%@%@", @(meters), NSLocalizedString(@"DISTANCE_M", nil)];
        }
        
        NSUInteger timeInMinutes = (NSUInteger)ceil(route.expectedTravelTime / 60);
        NSUInteger hours = (NSUInteger)floor(timeInMinutes / 60);
        NSUInteger minutes = (NSUInteger)(timeInMinutes % 60);
        
        NSString *timeString;
        if (hours > 0) {
            timeString = [NSString stringWithFormat:@"%@%@ %@%@", @(hours), NSLocalizedString(@"TIME_H", nil), @(minutes), NSLocalizedString(@"TIME_M", nil)];
        } else {
            timeString = [NSString stringWithFormat:@"%@%@", @(minutes), NSLocalizedString(@"TIME_M", nil)];
        }
        
        self.routeInfoLabel.title = [NSString stringWithFormat:@"%@, %@", distanceString, timeString];
        self.routeInfoLabel.enabled = YES;

        self.backButton.enabled = !(self.selectedRouteNumber == 0);
        self.forwardButton.enabled = !(self.selectedRouteNumber == self.routes.count - 1);
        
//        if (self.backButton.enabled) [self addSwipeToRight];
//        if (self.forwardButton.enabled) [self addSwipeToLeft];
        
    } else {
        
        self.routeInfoLabel.title = NSLocalizedString(@"CALC ROUTES", nil);
        self.routeInfoLabel.enabled = YES;
        
        self.backButton.enabled = NO;
        self.forwardButton.enabled = NO;
        
    }
    
}

- (void)addSwipeToLeft {
    
    UISwipeGestureRecognizer *swipeToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(forwardButtonPressed:)];
    [self.toolbar addGestureRecognizer:swipeToLeft];
    
}

- (void)addSwipeToRight {

    UISwipeGestureRecognizer *swipeToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonPressed:)];
    [self.toolbar addGestureRecognizer:swipeToRight];

}

- (void)removeAllSwipes {
    
    for (UIGestureRecognizer *gesture in self.toolbar.gestureRecognizers) {
        
        if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
            [self.toolbar removeGestureRecognizer:gesture];
        }
        
    }
    
}

- (void)updateAll {
    
    [self updateToolbar];
    [self updateRoutesOverlays];
    [self updateMapView];

}

#pragma mark - actions

- (IBAction)backButtonPressed:(id)sender {
    
    self.selectedRouteNumber = (self.selectedRouteNumber != 0) ? self.selectedRouteNumber - 1 : 0;
    [self updateAll];
    
}

- (IBAction)forwardButtonPressed:(id)sender {
    
    self.selectedRouteNumber = (self.selectedRouteNumber != self.routes.count - 1) ? self.selectedRouteNumber + 1 : self.routes.count - 1;
    [self updateAll];

}

- (IBAction)routeInfoPressed:(id)sender {
    
    if (self.routes.count > 0) {
        
        [self showRouteInfoAlert];
        
    } else {
        
        [self.view addSubview:self.spinner];
        [self calcRoute];
        
    }
    
}

- (void)showRouteInfoAlert {
    
    MKRoute *route = self.routes[self.selectedRouteNumber];
    
    NSString *message = @"";
    
    for (MKRouteStep *step in route.steps) {
        
        message = [message stringByAppendingString:step.instructions];
        message = [message stringByAppendingString:@"\n"];

    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:route.name
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    if (!self.startPoint) {
        
        self.startPoint = userLocation.location;
        [self setupMapView];

    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    
    MKRoute *route = self.routes[self.selectedRouteNumber];
    MKPolyline *currentRouteOverlay = route.polyline;
    
    UIColor *color = ([overlay isEqual:currentRouteOverlay]) ? [UIColor blueColor] : [UIColor colorWithRed:0 green:0 blue:1 alpha:.3];
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = color;
    renderer.lineWidth = 5.0;
    
    return renderer;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[STMMapAnnotation class]]) {
        
        static NSString *identifier = @"STMMapAnnotation";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        STMMapAnnotation *myAnnotation = (STMMapAnnotation *)annotation;
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        if ([myAnnotation isEqual:self.startPin]) {
            annotationView.pinColor = MKPinAnnotationColorRed;
        } else if ([myAnnotation isEqual:self.destinationPin]) {
            annotationView.pinColor = MKPinAnnotationColorPurple;
        }
        
        annotationView.canShowCallout = YES;
        annotationView.enabled = YES;
        
        return annotationView;
        
    } else {
        return nil;
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.spinner = [STMSpinnerView spinnerViewWithFrame:self.mapView.frame];
    [self.view addSubview:self.spinner];

    [self updateToolbar];
    [self setupMapView];
    
    self.routeInfoLabel.title = NSLocalizedString(@"CALC ROUTES", nil);
    self.routeInfoLabel.enabled = NO;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (![self.navigationController.viewControllers containsObject:self]) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
