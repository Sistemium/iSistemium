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
#import "STMConstants.h"
#import "STMCampaignDescriptionVC.h"

@interface STMCampaignDetailsPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *descriptionLabel;

@property (nonatomic, strong) UIPopoverController *campaignDescriptionPopover;

@property (nonatomic, strong) STMDocument *document;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;

//@property (nonatomic, strong) UIPopoverController *popover;

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

        BOOL isFirstAssign = NO;
        
        if (!_campaign) {
            
            isFirstAssign = YES;
            [self setupSegmentedControl];
            
        }
        
        _campaign = campaign;

        if (isFirstAssign) {
            self.dataSource = nil;
            self.dataSource = self;
        }
        
        [self showCampaignDescription];
        
        self.navigationItem.leftBarButtonItem.title = self.campaign.name;
        
//        [self.popover dismissPopoverAnimated:YES];
        
    }
    
}

- (STMCampaignPageCVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMCampaignPageCVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"campaignPictureCVC"];
            break;
            
        case 1:
            if (self.campaign) {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"campaignPhotoReportCVC"];
            }
            break;
            
        default:
            break;
            
    }
        
    vc.index = index;
    vc.campaign = self.campaign;
    
    return vc;
    
}

- (void)showCampaignDescription {

    NSString *campaignDescription = self.campaign.commentText;
    
    if (campaignDescription) {
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                     NSFontAttributeName:[UIFont systemFontOfSize:18]};
        [self.descriptionLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];

        CGSize size = [campaignDescription sizeWithAttributes:attributes];

        if (size.width > self.descriptionLabel.width) {

            attributes = @{NSForegroundColorAttributeName:ACTIVE_BLUE_COLOR,
                           NSFontAttributeName:[UIFont systemFontOfSize:18]};
            [self.descriptionLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];

//            self.descriptionLabel.title = NSLocalizedString(@"CAMPAIGN TERMS", nil);
            self.descriptionLabel.title = [self truncString:campaignDescription toWidth:self.descriptionLabel.width withTextAttributes:attributes];
            self.descriptionLabel.enabled = YES;

        } else {
            
            self.descriptionLabel.title = campaignDescription;
            self.descriptionLabel.enabled = NO;
            
        }
        
    } else {
        
        self.descriptionLabel.title = @"";
        self.descriptionLabel.enabled = NO;

    }
    
}

- (NSString *)truncString:(NSString *)string toWidth:(CGFloat)width withTextAttributes:(NSDictionary *)attributes {

    if (string.length > 0) {

        string = [string substringToIndex:[string length] - 1];
        NSString *stringWithDots = [string stringByAppendingString:@"…"];
        NSDictionary *attributes = [self.descriptionLabel titleTextAttributesForState:UIControlStateNormal];
        CGSize size = [stringWithDots sizeWithAttributes:attributes];

        if (size.width > width) {
            return [self truncString:string toWidth:width withTextAttributes:attributes];
        } else {
            return stringWithDots;
        }
        
    } else {
        return nil;
    }

}

- (UIPopoverController *)campaignDescriptionPopover {
    
    if (!_campaignDescriptionPopover) {
        
        STMCampaignDescriptionVC *campaignDescriptionPopover = [self.storyboard instantiateViewControllerWithIdentifier:@"campaignDescriptionPopover"];
        campaignDescriptionPopover.descriptionText = self.campaign.commentText;
        
        _campaignDescriptionPopover = [[UIPopoverController alloc] initWithContentViewController:campaignDescriptionPopover];
        
    }
    
    return _campaignDescriptionPopover;
    
}

- (void)showDescriptionPopover {
    
    self.campaignDescriptionPopover = nil;
    [self.campaignDescriptionPopover presentPopoverFromBarButtonItem:self.descriptionLabel
                                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                                            animated:YES];

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

/*
#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    
    return NO;
    
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    NSString *barButtonTitle = self.campaign ? self.campaign.name : NSLocalizedString(@"AD CAMPAIGNS", nil);
    barButtonItem.title = barButtonTitle;
    
//    barButtonItem.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.popover = pc;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.popover = nil;
    
}
*/

#pragma mark

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
}

- (void)setupSegmentedControl {
    
    NSArray *titles = @[@"PICTURES", @"PHOTO REPORTS"];
    
    for (int i = 0; i < titles.count; i++) {
        [self.segmentedControl insertSegmentWithTitle:NSLocalizedString(titles[i], nil) atIndex:i animated:YES];
    }
    
    self.segmentedControl.selectedSegmentIndex = self.currentIndex;
    
    [self.segmentedControl addTarget:self action:@selector(selectSegmentedControlSegment) forControlEvents:UIControlEventValueChanged];

}

- (void)selectSegmentedControlSegment {
    
    UIPageViewControllerNavigationDirection direction;
    
    if (self.segmentedControl.selectedSegmentIndex > self.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    self.currentIndex = self.segmentedControl.selectedSegmentIndex;

    [self setVCAtIndex:self.currentIndex direction:direction];
    
}

- (void)setVCAtIndex:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {

    STMCampaignPageCVC *vc = [self viewControllerAtIndex:index storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:direction animated:YES completion:NULL];

}

- (void)descriptionLabelSetup {
    
    self.descriptionLabel.title = @"";
    self.descriptionLabel.enabled = NO;
    
    [self.descriptionLabel setTarget:self];
    [self.descriptionLabel setAction:@selector(showDescriptionPopover)];

}

#pragma mark - viewlifecycle

- (void)customInit {
    
    self.dataSource = self;
    self.delegate = self;
    
    self.currentIndex = 0;
    [self setVCAtIndex:self.currentIndex direction:UIPageViewControllerNavigationDirectionForward];
    
    self.view.autoresizesSubviews = YES;
    
    [self descriptionLabelSetup];
    
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
    
    [self.segmentedControl removeAllSegments];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidDisappear:animated];
    
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
