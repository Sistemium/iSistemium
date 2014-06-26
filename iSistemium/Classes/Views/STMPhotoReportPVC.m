//
//  STMPhotoReportPVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportPVC.h"
#import "STMPhotoVC.h"

@interface STMPhotoReportPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSUInteger nextIndex;
@property (nonatomic, strong) NSArray *photoArray;

@end

@implementation STMPhotoReportPVC

- (NSArray *)photoArray {
    
    if (!_photoArray) {
        
        _photoArray = [self.photoReport.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO selector:@selector(compare:)]]];
        
    }
    
    return _photoArray;
    
}

- (STMPhotoVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    if ((self.photoReport.photos.count == 0) || (index >= self.photoReport.photos.count)) {
        
        return nil;
        
    } else {
        
        STMPhotoVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"photoVC"];
        
        vc.photo = self.photoArray[index];
        vc.index = index;
        
        return vc;
        
    }
    
}

- (void)refreshTitle {
    
//    self.title = [(STMCampaignPicture *)self.picturesArray[self.currentIndex] name];
    
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    return [self viewControllerAtIndex:self.currentIndex-1 storyboard:self.storyboard];
    //    return self.viewControllers[self.currentIndex-1];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    return [self viewControllerAtIndex:self.currentIndex+1 storyboard:self.storyboard];
    //    return self.viewControllers[self.currentIndex+1];
    
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    STMPhotoVC *pendingVC = pendingViewControllers[0];
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        
        self.currentIndex = self.nextIndex;
        //        self.title = [(STMCampaignPicture *)self.picturesArray[self.currentIndex] name];
        [self refreshTitle];
        
    }
}

#pragma mark - view lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.dataSource = self;
    self.delegate = self;
    
    STMPhotoVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    [self refreshTitle];

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
