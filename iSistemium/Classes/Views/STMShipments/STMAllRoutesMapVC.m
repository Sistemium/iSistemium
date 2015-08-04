//
//  STMAllRoutesMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAllRoutesMapVC.h"
#import "STMDataModel.h"
#import "STMLocationController.h"
#import "STMMapAnnotation.h"

#import "STMUI.h"

#import "STMReorderRoutePointsTVC.h"


#define EDGE_INSET 50


@interface STMAllRoutesMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *routesInfoLabel;

@property (nonatomic, strong) NSMutableArray *locationsArray;

@property (nonatomic, strong) STMMapAnnotation *startPin;
@property (nonatomic, strong) NSArray *locationsPins;

@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic) NSTimeInterval routesOverallTime;
@property (nonatomic) CLLocationDistance routesOverallDistance;

@property (nonatomic, strong) STMSpinnerView *spinner;


@end


@implementation STMAllRoutesMapVC

- (NSMutableArray *)locationsArray {
    
    if (!_locationsArray) {
        _locationsArray = [NSMutableArray array];
    }
    return _locationsArray;
    
}

- (NSMutableArray *)routes {
    
    if (!_routes) {
        _routes = [NSMutableArray array];
    }
    return _routes;
    
}

- (void)prepareArrayOfCLLocations {
    
    self.locationsArray = nil;
        
    NSMutableArray *pins = [NSMutableArray array];
    
    if (self.points.count > 0) {
        
        for (STMShipmentRoutePoint *point in self.points) {
            
            STMLocation *pointLocation = point.shippingLocation.location;
            CLLocation *location = [STMLocationController locationFromLocationObject:pointLocation];
            [self.locationsArray addObject:location];
            
            STMMapAnnotation *pin = [STMMapAnnotation createAnnotationForCLLocation:location
                                                                          withTitle:point.shortName
                                                                        andSubtitle:point.address
                                                                             andOrd:point.ord];
            [pins addObject:pin];

        }
        
        self.locationsPins = pins.copy;
        
    }
    
}

- (void)setupMapView {
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    [self updateMapView];

}

- (void)updateMapView {

    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (!self.startPoint) {
        
        [self.mapView showAnnotations:self.locationsPins animated:YES];
        
    } else {
        
        self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint
                                                              withTitle:NSLocalizedString(@"START POINT", nil)
                                                            andSubtitle:nil];
        
        NSArray *pins = [self.locationsPins arrayByAddingObject:self.startPin];
        
        [self.mapView showAnnotations:pins animated:YES];
        [self calcRoutes];
        
    }

}

- (void)recalcRoutes {
    
    [self.view addSubview:self.spinner];

    self.points = [self.points sortedArrayUsingDescriptors:[self.parentVC shipmentRoutePointsSortDescriptors]];
    
    [self prepareArrayOfCLLocations];
    [self updateMapView];
    
}

- (void)calcRoutes {
    
    self.routes = nil;
    
    NSArray *points = [[@[self.startPoint] arrayByAddingObjectsFromArray:self.locationsArray] arrayByAddingObject:self.startPoint];
    
    for (int i = 0; i < points.count - 1; i++) {
        
        CLLocation *startLocation = points[i];
        CLLocation *finishLocation = points[i+1];
        
        [self calcRouteFromStartLocation:startLocation toFinishLocation:finishLocation];
        
    }
    
}

- (void)calcRouteFromStartLocation:(CLLocation *)startLocation toFinishLocation:(CLLocation *)finishLocation {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    MKPlacemark *start = [[MKPlacemark alloc] initWithCoordinate:startLocation.coordinate addressDictionary:nil];
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:finishLocation.coordinate addressDictionary:nil];
    
    request.source = [[MKMapItem alloc] initWithPlacemark:start];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destination];
    
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (!error) {
            
            [self.routes addObject:response.routes.firstObject];
            
            if (self.routes.count == self.points.count + 1) {
                [self showRoutes];
            }
            
        }
        
    }];

}

- (void)showRoutes {

    [self.spinner removeFromSuperview];
    
    [self.mapView removeOverlays:self.mapView.overlays];

    self.routesOverallDistance = 0;
    self.routesOverallTime = 0;

    MKMapRect polylineRect;
    
    for (MKRoute *route in self.routes) {
        
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        if ([route isEqual:self.routes.firstObject]) {
            polylineRect = route.polyline.boundingMapRect;
        } else {
            polylineRect = MKMapRectUnion(polylineRect, route.polyline.boundingMapRect);
        }
        
        self.routesOverallTime += route.expectedTravelTime;
        self.routesOverallDistance += route.distance;
        
    }

    [self.mapView setVisibleMapRect:polylineRect
                        edgePadding:UIEdgeInsetsMake(EDGE_INSET, EDGE_INSET, EDGE_INSET, EDGE_INSET)
                           animated:YES];
    
    [self updateRoutesInfoLabel];
    
}

- (void)updateRoutesInfoLabel {

    self.routesInfoLabel.enabled = NO;
//    self.routesInfoLabel.tintColor = [UIColor blackColor];

    if (self.routes.count > 0) {
        
        NSUInteger distanceInKm = (NSUInteger)floor(self.routesOverallDistance / 1000);
        NSUInteger meters = (NSUInteger)(self.routesOverallDistance - 1000 * distanceInKm);
        
        NSString *distanceString;
        if (distanceInKm > 0) {
            distanceString = [NSString stringWithFormat:@"%@%@ %@%@", @(distanceInKm), NSLocalizedString(@"DISTANCE_KM", nil), @(meters), NSLocalizedString(@"DISTANCE_M", nil)];
        } else {
            distanceString = [NSString stringWithFormat:@"%@%@", @(meters), NSLocalizedString(@"DISTANCE_M", nil)];
        }
        
        NSUInteger timeInMinutes = (NSUInteger)ceil(self.routesOverallTime / 60);
        NSUInteger hours = (NSUInteger)floor(timeInMinutes / 60);
        NSUInteger minutes = (NSUInteger)(timeInMinutes % 60);
        
        NSString *timeString;
        if (hours > 0) {
            timeString = [NSString stringWithFormat:@"%@%@ %@%@", @(hours), NSLocalizedString(@"TIME_H", nil), @(minutes), NSLocalizedString(@"TIME_M", nil)];
        } else {
            timeString = [NSString stringWithFormat:@"%@%@", @(minutes), NSLocalizedString(@"TIME_M", nil)];
        }
        
        self.routesInfoLabel.title = [NSString stringWithFormat:@"%@, %@", distanceString, timeString];
        
    } else {
        
        self.routesInfoLabel.title = @"";
        
    }
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!self.startPoint) {
        
        self.startPoint = userLocation.location;
        [self updateMapView];
        
    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {

    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];

    NSUInteger routeNumber = [[self.routes valueForKeyPath:@"polyline"] indexOfObject:overlay];
    CGFloat k = 0.5 / (self.routes.count - 1);
    CGFloat alfa = 1 - k * routeNumber;
    
    alfa = 1;

    renderer.strokeColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:alfa];
    renderer.lineWidth = 3.0;
    
    return renderer;
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[STMMapAnnotation class]]) {
        
        STMMapAnnotation *myAnnotation = (STMMapAnnotation *)annotation;

        MKPinAnnotationView *annotationView;
        
        if ([myAnnotation isEqual:self.startPin]) {

            static NSString *identifier = @"STMMapAnnotationStart";
            annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            if (!annotationView) {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
            } else {
                annotationView.annotation = annotation;
            }
            
        } else {
            
            static NSString *identifier = @"STMMapAnnotation";
            annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
            
            if (!annotationView) {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier];
            } else {
                annotationView.annotation = annotation;
            }

        }
        
        if ([myAnnotation isEqual:self.startPin]) {
            
            annotationView.pinColor = MKPinAnnotationColorRed;
            
        } else {
            
            if (myAnnotation.ord) {

                NSString *imageName = (myAnnotation.ord.integerValue < 9) ? [NSString stringWithFormat:@"%@_circle_colored_blue", @(myAnnotation.ord.integerValue + 1)] : @"circle_colored_blue";
                
                annotationView.image = [UIImage imageNamed:imageName];
                
            } else {
            
                annotationView.pinColor = MKPinAnnotationColorPurple;

            }
            
        }
        
        annotationView.canShowCallout = YES;
        
        return annotationView;
        
    } else {
        return nil;
    }
    
}


#pragma mark - navBar

- (void)setupNavBar {
    
    if (self.points.count > 0) {
        
        CGFloat imageSize = 22;
        CGFloat imagePadding = 0;
        
        UIImage *image = [[UIImage imageNamed:@"reordering"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(imagePadding, imagePadding, imageSize, imageSize);
        imageView.tintColor = ACTIVE_BLUE_COLOR;
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageSize + imagePadding * 2, imageSize + imagePadding * 2)];
        [button addTarget:self action:@selector(reorderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [button addSubview:imageView];

        STMBarButtonItem *reorderButton = [[STMBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = reorderButton;
                
    }
    
}

- (void)reorderButtonPressed {
    
    STMReorderRoutePointsTVC *reorderTVC = [[STMReorderRoutePointsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    reorderTVC.points = self.points;
    reorderTVC.parentVC = self;
    
    [self.navigationController pushViewController:reorderTVC animated:YES];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.spinner = [STMSpinnerView spinnerViewWithFrame:self.mapView.frame];
    [self.view addSubview:self.spinner];
    
    [self setupNavBar];
    [self prepareArrayOfCLLocations];
    [self setupMapView];
    [self updateRoutesInfoLabel];
    
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
