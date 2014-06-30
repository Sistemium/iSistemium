//
//  STMCampaignDetailsPVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignDetailsPVC.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMRootTBC.h"
#import "STMCampaignPageCVC.h"

@interface STMCampaignDetailsPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIBarButtonItem *homeButton;
@property (nonatomic, strong) STMDocument *document;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;

@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation STMCampaignDetailsPVC


- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (void)setCampaign:(STMCampaign *)campaign {
    
    if (campaign != _campaign) {
        
        self.title = campaign.name;
        
        for (STMCampaignPageCVC *view in self.viewControllers) {
            view.campaign = campaign;
        }
        
        if (self.segmentedControl.numberOfSegments == 0) {
            [self setupSegmentedControl];
        }
        
        _campaign = campaign;
        
        [self.popover dismissPopoverAnimated:YES];
        
    }
    
}

- (UIBarButtonItem *)homeButton {
    
    if (!_homeButton) {
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HOME", nil) style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed)];
        
        _homeButton = button;
        
    }
    
    return _homeButton;
    
}

- (void)homeButtonPressed {
    
    //    NSLog(@"homeButtonPressed");
    [[STMRootTBC sharedRootVC] showTabWithName:@"STMAuthTVC"];
    
    
}

- (STMCampaignPageCVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMCampaignPageCVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"campaignPictureCVC"];
            break;
            
        case 1:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"campaignPhotoReportCVC"];
            break;
            
        default:
            break;
            
    }
    
    vc.index = index;
    vc.campaign = self.campaign;
        
    return vc;
    
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    return [self viewControllerAtIndex:self.currentIndex-1 storyboard:self.storyboard];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    return [self viewControllerAtIndex:self.currentIndex+1 storyboard:self.storyboard];
    
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    STMCampaignPageCVC *pendingVC = pendingViewControllers[0];
    pendingVC.campaign = self.campaign;
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        
        STMCampaignPageCVC *previousVC = previousViewControllers[0];
        previousVC.campaign = self.campaign;
        self.currentIndex = self.nextIndex;
        
        self.segmentedControl.selectedSegmentIndex = self.currentIndex;
        
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.popover = pc;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.popover = nil;
    
}


#pragma mark

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
}

- (void)setupSegmentedControl {
    
    NSArray *titles = @[@"CAMPAIGNS", @"PHOTO REPORTS"];
    
    for (int i = 0; i < titles.count; i++) {
        [self.segmentedControl insertSegmentWithTitle:NSLocalizedString(titles[i], nil) atIndex:i animated:YES];
    }
    
    self.segmentedControl.selectedSegmentIndex = self.currentIndex;
    
    [self.segmentedControl addTarget:self action:@selector(selectSegmentedControlSegment) forControlEvents:UIControlEventValueChanged];

}

- (void)selectSegmentedControlSegment {
    
    NSLog(@"selectedSegmentIndex %d", self.segmentedControl.selectedSegmentIndex);
    
    STMCampaignPageCVC *vc = [self viewControllerAtIndex:self.segmentedControl.selectedSegmentIndex storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    
    UIPageViewControllerNavigationDirection direction;
    
    if (self.segmentedControl.selectedSegmentIndex > self.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    [self setViewControllers:viewControllers direction:direction animated:YES completion:NULL];
    
}

#pragma mark - viewlifecycle

- (void)customInit {
    
    self.navigationItem.rightBarButtonItem = self.homeButton;

    self.dataSource = self;
    self.delegate = self;
    
    self.currentIndex = 0;
    
    STMCampaignPageCVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
}


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
    [self customInit];
    
    [self.segmentedControl removeAllSegments];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
