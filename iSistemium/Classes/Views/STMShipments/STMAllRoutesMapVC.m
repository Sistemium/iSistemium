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

#define EDGE_INSET 50


@interface STMAllRoutesMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *locationsArray;

@property (nonatomic, strong) STMMapAnnotation *startPin;
@property (nonatomic, strong) NSArray *locationsPins;

@property (nonatomic, strong) NSMutableArray *routes;


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

- (NSArray *)locationsPins {
    
    if (!_locationsPins) {

        if (self.locationsArray.count > 0) {
            
            NSMutableArray *pins = [NSMutableArray array];
            
            for (CLLocation *location in self.locationsArray) {
                
                STMMapAnnotation *pin = [STMMapAnnotation createAnnotationForCLLocation:location];
                [pins addObject:pin];
                
            }
            
            _locationsPins = pins.copy;
            
        }
        
    }
    return _locationsPins;
    
}

- (void)prepareArrayOfCLLocations {
    
    self.locationsArray = nil;
    
    if (self.points.count > 0) {
        
        for (STMShipmentRoutePoint *point in self.points) {
            
            STMLocation *pointLocation = point.shippingLocation.location;
            CLLocation *location = [STMLocationController locationFromLocationObject:pointLocation];
            [self.locationsArray addObject:location];
            
        }
        
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
        
        self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint];
        NSArray *pins = [self.locationsPins arrayByAddingObject:self.startPin];
        
        [self.mapView showAnnotations:pins animated:YES];
        [self calcRoutes];
        
    }

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
    
    BOOL isLastRoute = ([finishLocation isEqual:self.startPoint]);
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (!error) {
            
            [self.routes addObject:response.routes.firstObject];
            
            if (isLastRoute) [self showRoutes];
            
        }
        
    }];

}

- (void)showRoutes {

    [self.mapView removeOverlays:self.mapView.overlays];

    MKMapRect polylineRect;
    
    for (MKRoute *route in self.routes) {
        
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        if ([route isEqual:self.routes.firstObject]) {
            polylineRect = route.polyline.boundingMapRect;
        } else {
            polylineRect = MKMapRectUnion(polylineRect, route.polyline.boundingMapRect);
        }
        
    }

    [self.mapView setVisibleMapRect:polylineRect
                        edgePadding:UIEdgeInsetsMake(EDGE_INSET, EDGE_INSET, EDGE_INSET, EDGE_INSET)
                           animated:YES];
    
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
    renderer.strokeColor = [UIColor blueColor];
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
        } else {
            annotationView.pinColor = MKPinAnnotationColorPurple;
        }
        
        return annotationView;
        
    } else {
        return nil;
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self prepareArrayOfCLLocations];
    [self setupMapView];
    
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
    
    if ([self isViewLoaded] && [self.view window] == nil) {
        
        [self flushMapView];
        self.view = nil;
        
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
