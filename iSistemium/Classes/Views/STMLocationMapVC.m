//
//  STMLocationMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMLocationMapVC.h"
#import "STMFunctions.h"
#import "STMMapAnnotation.h"


@interface STMLocationMapVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end


@implementation STMLocationMapVC

- (void)centeringMap {

    self.mapView.showsUserLocation = YES;
    [self.mapView addAnnotation:[STMMapAnnotation createAnnotationForLocation:self.location]];

    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(self.location.latitude.doubleValue, self.location.longitude.doubleValue);
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinate.latitude longitude:locationCoordinate.longitude];
    
//    CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
//    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:userCoordinate.latitude longitude:userCoordinate.longitude];
//    
//    CLLocationDistance distance = [location distanceFromLocation:userLocation];
    
    CLLocationDistance distance = 10000;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, distance, distance);
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
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
