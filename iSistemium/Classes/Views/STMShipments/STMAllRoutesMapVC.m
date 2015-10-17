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
#import "STMShipmentRoutePointTVC.h"


#define EDGE_INSET 50
#define PICKER_SUPERVIEW_HEIGHT 88

typedef NS_ENUM(NSUInteger, STMMapReorderingMode) {
    STMMapReorderingModeUnknown,
    STMMapReorderingModeEnable,
    STMMapReorderingModeDisable
};


@interface STMAllRoutesMapVC () <MKMapViewDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) STMShipmentsSVC *splitVC;

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

@property (atomic) NSUInteger routesCalcCounter;
@property (nonatomic, strong) NSMutableString *routesCalcErrors;

@property (nonatomic, strong) UIProgressView *progressBar;

@property (nonatomic, strong) UIPickerView *ordPicker;
@property (nonatomic, strong) UIView *pickerSuperview;
//@property (nonatomic, strong) STMShipmentRoutePoint *selectedPoint;
@property (nonatomic, strong) STMMapAnnotation *selectedPin;

@property (nonatomic, strong) STMBarButtonItem *reorderButton;
@property (nonatomic) STMMapReorderingMode reorderingMode;


@end


@implementation STMAllRoutesMapVC

- (STMShipmentsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.parentVC.splitViewController isKindOfClass:[STMShipmentsSVC class]]) {
            _splitVC = (STMShipmentsSVC *)self.parentVC.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMBarButtonItem *)reorderButton {
    
    if (!_reorderButton) {
        
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

        _reorderButton = reorderButton;
        
    }
    return _reorderButton;
    
}

- (UIPickerView *)ordPicker {

    if (!_ordPicker) {
        
        CGRect pickerFrame = CGRectMake(0, 0, self.view.frame.size.width, 162); // UIPicker height may be 162, 180 and 216 only
        
        _ordPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        
        _ordPicker.dataSource = self;
        _ordPicker.delegate = self;

    }
    return _ordPicker;
    
}

- (UIView *)pickerSuperview {

    if (!_pickerSuperview) {
        
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, PICKER_SUPERVIEW_HEIGHT);
        
        _pickerSuperview = [[UIView alloc] initWithFrame:frame];
        _pickerSuperview.clipsToBounds = YES;
        _pickerSuperview.backgroundColor = [UIColor whiteColor];
        self.ordPicker.center = _pickerSuperview.center;
        
        [_pickerSuperview addSubview:self.ordPicker];
        
    }
    return _pickerSuperview;
    
}

- (UIProgressView *)progressBar {
    
    if (!_progressBar) {

        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressBar = progressView;
        
    }
    return _progressBar;
    
}

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

- (void)setPoints:(NSArray *)points {
    
    _points = points;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self prepareArrayOfCLLocations];

    self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint
                                                          withTitle:NSLocalizedString(@"START POINT", nil)
                                                        andSubtitle:nil];
    
    NSArray *pins = [self.locationsPins arrayByAddingObject:self.startPin];
    
    [self.mapView addAnnotations:pins];

}

- (void)setReorderingMode:(STMMapReorderingMode)reorderingMode {
    
    if (self.reorderingMode != reorderingMode) {
        
        if (reorderingMode == STMMapReorderingModeEnable) {
            
            [self showOrdPickerView];
            
            STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(reorderDoneButtonPressed)];
            self.navigationItem.rightBarButtonItem = doneButton;

        } else if (reorderingMode == STMMapReorderingModeDisable) {
            
            [self hideOrdPicker];
            self.navigationItem.rightBarButtonItem = self.reorderButton;
            self.selectedPin = nil;
            
#warning - do not recalculate routes if no changes
            
            [self recalcRoutes];

        }
        
        _reorderingMode = reorderingMode;
        
    }
    
}

- (void)prepareArrayOfCLLocations {
    
    self.locationsArray = nil;
        
    NSMutableArray *pins = [NSMutableArray array];
    
    if (self.points.count > 0) {
        
        for (STMShipmentRoutePoint *point in self.points) {
            
            if ((point.shippingLocation.location)) {

                CLLocation *location = [STMLocationController locationFromLocationObject:point.shippingLocation.location];

                [self.locationsArray addObject:location];
                
//                STMMapAnnotation *pin = [STMMapAnnotation createAnnotationForCLLocation:location
//                                                                              withTitle:[STMFunctions shortCompanyName:point.shortName]
//                                                                            andSubtitle:point.address
//                                                                                 andOrd:point.ord];

                STMMapAnnotation *pin = [STMMapAnnotation createAnnotationForPoint:point];

                [pins addObject:pin];

            }

        }
        
        self.locationsPins = pins.copy;
        
    }
    
}

- (void)setupMapView {
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

//    [self performSelector:@selector(updateMapView) withObject:nil afterDelay:0];
    [self updateMapView];

}

- (void)updateMapView {

    [self.mapView performSelector:@selector(removeAnnotations:) withObject:self.mapView.annotations afterDelay:0];
    
//    [self.mapView removeAnnotations:self.mapView.annotations];
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        if (!self.startPoint) {
            
            [self performSelector:@selector(showAnnotationsWithAnimation:) withObject:self.locationsPins afterDelay:0];
            
//            [self.mapView showAnnotations:self.locationsPins animated:YES];
            
        } else {

            self.startPin = [STMMapAnnotation createAnnotationForCLLocation:self.startPoint
                                                                  withTitle:NSLocalizedString(@"START POINT", nil)
                                                                andSubtitle:nil];
            
            NSArray *pins = [self.locationsPins arrayByAddingObject:self.startPin];
            
            [self performSelector:@selector(showAnnotationsWithAnimation:) withObject:pins afterDelay:0];

//            [self.mapView showAnnotations:pins animated:YES];

            [self calcRoutes];
            
        }
        
//    }];

}

- (void)showAnnotationsWithAnimation:(NSArray *)annotations {
    [self.mapView showAnnotations:annotations animated:YES];
}

- (void)recalcRoutes {
    
    [self.view addSubview:self.spinner];
    
    NSArray *sortDescriptors = [self.parentVC shipmentRoutePointsSortDescriptors];
    
    if (sortDescriptors) {
        self.points = [self.points sortedArrayUsingDescriptors:(NSArray * _Nonnull)sortDescriptors];
    }
    
    [self prepareArrayOfCLLocations];
//    [self performSelector:@selector(updateMapView) withObject:nil afterDelay:0];
    [self updateMapView];
    
}

- (void)calcRoutes {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startCalcRoutes" object:self];
    
    self.progressBar.progress = 0;
    self.progressBar.center = CGPointMake(self.spinner.center.x, self.spinner.center.y + 40);
    [self.spinner removeFromSuperview];
    [self.spinner addSubview:self.progressBar];
    
    self.routes = nil;
    self.routesCalcCounter = 0;
    self.routesCalcErrors = [NSMutableString string];
    self.routesInfoLabel.title = NSLocalizedString(@"CALC ROUTES", nil);
    
    if (self.locationsArray.count > 1) {
        
//        NSArray *points = [[@[self.startPoint] arrayByAddingObjectsFromArray:self.locationsArray] arrayByAddingObject:self.startPoint];
        NSArray *points = self.locationsArray.copy;
        
        for (int i = 0; i < points.count - 1; i++) {
            
            CLLocation *startLocation = points[i];
            CLLocation *finishLocation = points[i+1];
            
            [self calcRouteFromStartLocation:startLocation toFinishLocation:finishLocation];
            
        }

    } else {
        [self.spinner removeFromSuperview];
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
        
        self.routesCalcCounter ++;
        
        float progress = (float)self.routesCalcCounter / (self.locationsArray.count - 1);
        [self.progressBar setProgress:progress animated:YES];

        if (!error) {
            if (response.routes.firstObject) [self.routes addObject:(id _Nonnull)response.routes.firstObject];
        } else {
            [self.routesCalcErrors appendFormat:@"%lu. %@\n\n", (unsigned long)self.routesCalcCounter, error.localizedDescription];
        }
        
        if (self.routesCalcCounter == self.locationsArray.count - 1) {
            
            [self.spinner removeFromSuperview];
            [self.progressBar removeFromSuperview];
            
            if (self.routesCalcErrors.length > 0) {
                [self showRoutesCalcErrors];
            }
            
            if (self.routes.count > 0) {
                [self showRoutes];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishCalcRoutes" object:self];

        }

    }];

}

- (void)showRoutesCalcErrors {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:self.routesCalcErrors
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:NSLocalizedString(@"RECALC", nil), nil];
        alert.tag = 111;
        [alert show];

    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 111: {
            
            switch (buttonIndex) {
                case 1: {
                    [self recalcRoutes];
                    break;
                }
                default: {
                    break;
                }
            }
            
            break;
        }
        default: {
            break;
        }
    }
    
}

- (void)showRoutes {
    
    [self.mapView removeOverlays:self.mapView.overlays];

    self.routesOverallDistance = 0;
    self.routesOverallTime = 0;

    MKMapRect polylineRect = {MKMapPointMake(0, 0), MKMapSizeMake(0, 0)};
    
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
//        [self performSelector:@selector(updateMapView) withObject:nil afterDelay:0];
        [self updateMapView];
        
    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {

    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];

//    NSUInteger routeNumber = [[self.routes valueForKeyPath:@"polyline"] indexOfObject:overlay];
//    CGFloat k = 0.5 / (self.routes.count - 1);
//    CGFloat alfa = 1 - k * routeNumber;
    
    CGFloat alfa = 1;

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
            annotationView = [self annotationViewForAnnotation:annotation WithIdentifier:identifier];
            
            annotationView.pinColor = MKPinAnnotationColorRed;

        } else {
            
            static NSString *identifier = @"STMMapAnnotation";
            annotationView = [self annotationViewForAnnotation:annotation WithIdentifier:identifier];
            
            if (myAnnotation.ord) {
                
                UIImage *circleImage = nil;
                
                if ([myAnnotation.point isEqual:self.selectedPin.point]) {
                    
                    circleImage = [UIImage imageNamed:@"circle_colored_red"];
                    self.selectedPin = myAnnotation;
                    
                } else {
                    circleImage = [UIImage imageNamed:@"circle_colored_blue"];
                }
                
                UIImage *image = [STMFunctions drawText:myAnnotation.ord.stringValue
                                               withFont:[UIFont systemFontOfSize:10]
                                                  color:[UIColor whiteColor]
                                                inImage:circleImage
                                               atCenter:YES];
                
                annotationView.image = image;
                
            } else {
                
                annotationView.pinColor = MKPinAnnotationColorPurple;
                
            }
            
            if (![self.splitVC isDetailNCForViewController:self]) {

                UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                CGSize size = infoButton.frame.size;
                infoButton.frame = CGRectMake(0, 0, size.width + 10, size.height);
                infoButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
                
                annotationView.rightCalloutAccessoryView = infoButton;

            }

        }
        
        annotationView.canShowCallout = YES;
        
        return annotationView;
        
    } else {
        return nil;
    }
    
}

- (MKPinAnnotationView *)annotationViewForAnnotation:(id <MKAnnotation>)annotation WithIdentifier:(NSString *)identifier {
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"showPoint" sender:view.annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[STMMapAnnotation class]] && ![view.annotation isEqual:self.selectedPin] && self.reorderingMode == STMMapReorderingModeEnable) {
        
        STMMapAnnotation *selectedPin = (STMMapAnnotation *)view.annotation;
        STMShipmentRoutePoint *point = selectedPin.point;
        
        [self.mapView removeAnnotation:selectedPin];
        
        if (self.selectedPin) {
            
            [self.mapView removeAnnotation:self.selectedPin];
            
        }
        
        BOOL wasSelectedPin = (self.selectedPin) ? YES : NO;
        
        STMMapAnnotation *previousPin = self.selectedPin;
        
        self.selectedPin = selectedPin;
        
        if (!wasSelectedPin) [self.ordPicker reloadAllComponents];

        [self.mapView addAnnotation:selectedPin];
        if (previousPin) [self.mapView addAnnotation:previousPin];
        
        [self.ordPicker selectRow:(point.ord.integerValue - 1) inComponent:0 animated:YES];

    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSInteger fromIndex = self.selectedPin.ord.integerValue - 1;
    NSInteger toIndex = row;
    
    NSUInteger minIndex = MIN(fromIndex, toIndex);
    NSUInteger loc = (minIndex == fromIndex) ? minIndex + 1 : minIndex;
    
    NSRange affectedPointsRange = NSMakeRange(loc, labs(fromIndex - toIndex));
    
    NSArray *affectedPoints = [self.points subarrayWithRange:affectedPointsRange];
    
    for (STMShipmentRoutePoint *point in affectedPoints) {
        point.ord = (minIndex == fromIndex) ? @(point.ord.integerValue - 1) : @(point.ord.integerValue + 1);
    }
    
//    STMShipmentRoutePoint *movedPoint = self.points[fromIndex];
//    movedPoint.ord = @(toIndex);

    self.selectedPin.point.ord = @(row + 1);
    
    NSArray *sortDescriptors = [self.parentVC shipmentRoutePointsSortDescriptors];
    
    if (sortDescriptors) {
        self.points = [self.points sortedArrayUsingDescriptors:(NSArray * _Nonnull)sortDescriptors];
    }

//    NSLog(@"row %d", row);
    
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showPoint"] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentRoutePointTVC class]] &&
        [sender isKindOfClass:[STMMapAnnotation class]]) {
        
        STMShipmentRoutePointTVC *pointTVC = (STMShipmentRoutePointTVC *)segue.destinationViewController;
        
        STMMapAnnotation *annotation = (STMMapAnnotation *)sender;
        
        STMShipmentRoutePoint *point = self.points[annotation.ord.integerValue - 1];
        
        pointTVC.point = point;
        
    }
    
}


#pragma mark - navBar

- (void)setupNavBar {
    
    if ([self.splitVC isDetailNCForViewController:self.parentVC]) {
        
        self.navigationItem.hidesBackButton = YES;

    } else {
     
        if (self.points.count > 0) {
            
            self.navigationItem.rightBarButtonItem = self.reorderButton;
            
            //        if ([self.splitVC isDetailNCForViewController:self.parentVC]) {
            //
            //            STMBarButtonItem *closeButton = [[STMBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil)
            //                                                                              style:UIBarButtonItemStylePlain
            //                                                                             target:self
            //                                                                             action:@selector(closeButtonPressed)];
            //            
            //            self.navigationItem.leftBarButtonItem = closeButton;
            //            
            //        }
            
        }
        
    }
    
}

- (void)reorderButtonPressed {

    if (IPAD) {
        
        STMReorderRoutePointsTVC *reorderTVC = [[STMReorderRoutePointsTVC alloc] initWithStyle:UITableViewStylePlain];
        reorderTVC.points = self.points;
        reorderTVC.parentVC = self;
        
        reorderTVC.edgesForExtendedLayout=UIRectEdgeNone;
        reorderTVC.extendedLayoutIncludesOpaqueBars=NO;
        reorderTVC.automaticallyAdjustsScrollViewInsets=NO;
        
        [self.navigationController pushViewController:reorderTVC animated:YES];

    } else {
        
        self.reorderingMode = STMMapReorderingModeEnable;
        
    }
    
}

- (void)reorderDoneButtonPressed {
    
    self.reorderingMode = STMMapReorderingModeDisable;
    
}

- (void)closeButtonPressed {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


- (void)showOrdPickerView {

    [self.ordPicker reloadAllComponents];
    [self.view addSubview:self.pickerSuperview];
    [self changeMapViewFrameWithPickerPresent:YES];

}

- (void)hideOrdPicker {

    [self changeMapViewFrameWithPickerPresent:NO];
    [self.pickerSuperview removeFromSuperview];
    
}

- (void)changeMapViewFrameWithPickerPresent:(BOOL)pickerPresent {

    CGRect mapFrame = self.mapView.frame;
    CGFloat shift = (pickerPresent) ? self.pickerSuperview.frame.size.height : - self.pickerSuperview.frame.size.height;
    CGFloat y = mapFrame.origin.y + shift;
    CGFloat height = mapFrame.size.height - shift;
    
    self.mapView.frame = CGRectMake(mapFrame.origin.x, y, mapFrame.size.width, height);

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return (self.selectedPin) ? self.points.count : 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return (self.selectedPin) ? @(row+1).stringValue : NSLocalizedString(@"SELECT POINT", nil);
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    if (![self.splitVC isDetailNCForViewController:self]) {
        self.reorderingMode = STMMapReorderingModeDisable;
    } else {
        self.reorderingMode = STMMapReorderingModeUnknown;
    }
    
//    self.spinner = [STMSpinnerView spinnerViewWithFrame:self.mapView.frame];
//    [self.view addSubview:self.spinner];
    
//    [self setupNavBar];
    [self prepareArrayOfCLLocations];
    [self updateRoutesInfoLabel];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    [super viewWillAppear:animated];
    [self setupNavBar];

}

- (void)viewDidAppear:(BOOL)animated {
    
    if ([self isMovingToParentViewController]) {
        
        self.spinner = [STMSpinnerView spinnerViewWithFrame:self.mapView.frame];
        [self.view addSubview:self.spinner];

        [self setupMapView];

    }
    
//    [self showUIPickerView];
    
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

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
