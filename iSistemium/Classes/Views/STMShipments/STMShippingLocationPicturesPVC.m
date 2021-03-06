//
//  STMShippingLocationPicturesPVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingLocationPicturesPVC.h"
#import "STMShippingLocationPictureVC.h"

#import "STMObjectsController.h"


@interface STMShippingLocationPicturesPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) STMPhoto *photo;
@property (nonatomic) NSUInteger nextIndex;


@end


@implementation STMShippingLocationPicturesPVC

- (STMShippingLocationPictureVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    if ((self.photoArray.count == 0) || (index >= self.photoArray.count)) {
        
        return nil;
        
    } else {
        
        STMShippingLocationPictureVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"photoVC"];
        STMPhoto *photo = self.photoArray[index];
        
        vc.index = index;
        vc.photo = photo;
        
        return vc;
        
    }
    
}

- (void)dismissView {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self removeObservers];
        
    }];
    
}

- (void)deletePhoto:(NSNotification *)notification {
    
    STMPhoto *photo = (notification.userInfo)[@"photo2delete"];
//    STMShippingLocation *location = photo.shippingLocation;
    
    [STMObjectsController createRecordStatusAndRemoveObject:photo];
    
    [self.parentVC photoWasDeleted:photo];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosCountChanged" object:self];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoReportsChanged" object:self userInfo:@{@"campaign": campaign}];
    
    if (self.photoArray.count == 1) {
        
        [self dismissView];
        
    } else {
        
        self.dataSource = nil;
        
        UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
        
        if (self.currentIndex == self.photoArray.count - 1) {
            
            self.currentIndex -= 1;
            direction = UIPageViewControllerNavigationDirectionReverse;
            
        }
        
        [self.photoArray removeObject:photo];
        self.dataSource = self;
        
        STMShippingLocationPictureVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
        
        __weak typeof(self) weakSelf = self;
        
        [self setViewControllers:@[vc] direction:direction animated:YES completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf setViewControllers:@[vc] direction:direction animated:NO completion:nil];
            });
        }];
        
    }
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    UIViewController *vc = [self viewControllerAtIndex:self.currentIndex-1 storyboard:self.storyboard];
    return vc;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    UIViewController *vc = [self viewControllerAtIndex:self.currentIndex+1 storyboard:self.storyboard];
    return vc;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return self.photoArray.count;
    
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return self.currentIndex;
    
}


#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    STMShippingLocationPictureVC *pendingVC = pendingViewControllers[0];
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        self.currentIndex = self.nextIndex;
    }
    
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissView) name:@"photoViewTap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhoto:) name:@"deletePhoto" object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[self class], nil];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = self;
    self.delegate = self;
    
    STMShippingLocationPictureVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    [self addObservers];
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
