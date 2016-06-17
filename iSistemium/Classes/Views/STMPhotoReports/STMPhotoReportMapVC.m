//
//  STMPhotoReportMapVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportMapVC.h"

#import <MapKit/MapKit.h>

#import "STMMapAnnotation.h"


@interface STMPhotoReportMapVC () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end


@implementation STMPhotoReportMapVC

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPhotoReportPin {
    
    if (self.photoReport.location) {
        
        STMMapAnnotation *pin = [STMMapAnnotation createAnnotationForLocation:self.photoReport.location
                                                                    withTitle:self.photoReport.campaign.name
                                                                  andSubtitle:self.photoReport.outlet.name];
        
        [self.mapView showAnnotations:@[pin] animated:YES];
        
    }
    
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[STMMapAnnotation class]]) {
        
        static NSString *identifier = @"STMMapAnnotation";
        MKPinAnnotationView *annotationView = [self annotationViewForAnnotation:annotation WithIdentifier:identifier];
        
        if (self.photoReport.imageThumbnail) {
            
            UIImage *image = [UIImage imageWithData:(NSData * _Nonnull)self.photoReport.imageThumbnail];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, annotationView.frame.size.height, annotationView.frame.size.height)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            
            annotationView.leftCalloutAccessoryView = imageView;
            
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


#pragma mark - view lifecycle

- (void)customInit {
    
    self.mapView.delegate = self;
    [self showPhotoReportPin];
    self.closeButton.title = NSLocalizedString(@"CLOSE", nil);
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
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
