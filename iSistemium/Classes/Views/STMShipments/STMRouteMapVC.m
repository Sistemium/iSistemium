//
//  STMRouteMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRouteMapVC.h"
#import "STMMapAnnotation.h"


@interface STMRouteMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) STMMapAnnotation *startPin;
@property (nonatomic, strong) STMMapAnnotation *destinationPin;


@end


@implementation STMRouteMapVC

- (CLLocation *)startPoint {
    
    if (!_startPoint) {
        _startPoint = self.mapView.userLocation.location;
    }
    return _startPoint;
    
}

- (void)setupMapView {

    self.mapView.showsUserLocation = YES;

    if (!self.startPoint) {
        
        self.mapView.delegate = self;
        
    } else {

        if (self.destinationPoint) {
            
            self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint];
            self.destinationPin = [STMMapAnnotation createAnnotationForCLLocation:self.destinationPoint];
            [self.mapView addAnnotation:self.startPin];
            [self.mapView addAnnotation:self.destinationPin];
            
            CLLocationDegrees midLatitude = (self.startPoint.coordinate.latitude + self.destinationPoint.coordinate.latitude) / 2;
            CLLocationDegrees midLongitude = (self.startPoint.coordinate.longitude + self.destinationPoint.coordinate.longitude) / 2;
            CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(midLatitude, midLongitude);
            CLLocationDistance distance = [self.startPoint distanceFromLocation:self.destinationPoint];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate, distance, distance);
            
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

        }
        
    }
    
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {

    self.startPoint = userLocation.location;
    mapView.delegate = nil;
    [self setupMapView];
    
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
