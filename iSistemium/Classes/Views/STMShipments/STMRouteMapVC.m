//
//  STMRouteMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRouteMapVC.h"
#import "STMMapAnnotation.h"

#define DISTANCE_SCALE 1.5


@interface STMRouteMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) STMMapAnnotation *startPin;
@property (nonatomic, strong) STMMapAnnotation *destinationPin;


@end


@implementation STMRouteMapVC

- (void)setupMapView {

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    if (self.startPoint && self.destinationPoint) {
        
        self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint];
        self.destinationPin = [STMMapAnnotation createAnnotationForCLLocation:self.destinationPoint];
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

- (void)calcRoute {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *start = [[MKPlacemark alloc] initWithCoordinate:self.startPoint.coordinate addressDictionary:nil];
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:self.destinationPoint.coordinate addressDictionary:nil];
    
    request.source = [[MKMapItem alloc] initWithPlacemark:start];
    request.destination = [[MKMapItem alloc] initWithPlacemark:destination];
    
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
         if (!error) {
             [self showRoute:response];
         }
        
     }];

}

- (void)showRoute:(MKDirectionsResponse *)response {
    
    for (MKRoute *route in response.routes) {
        
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps) {
            NSLog(@"%@", step.instructions);
        }
        
    }
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    if (!self.startPoint) {
        
        self.startPoint = userLocation.location;
        [self setupMapView];

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
        } else if ([myAnnotation isEqual:self.destinationPin]) {
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
        
        return annotationView;
        
    } else {
        return nil;
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
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
