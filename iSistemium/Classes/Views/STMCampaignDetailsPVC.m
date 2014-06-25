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

@property (nonatomic, strong) UIBarButtonItem *homeButton;
@property (nonatomic, strong) STMDocument *document;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;



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
        
        _campaign = campaign;
        
//        [self.navigationController popToRootViewControllerAnimated:YES];
        
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
    self.nextIndex = pendingVC.index;
    
    NSLog(@"self.nextIndex %d", self.nextIndex);
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        
        self.currentIndex = self.nextIndex;
        
        NSLog(@"self.currentIndex %d", self.currentIndex);
        
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
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
