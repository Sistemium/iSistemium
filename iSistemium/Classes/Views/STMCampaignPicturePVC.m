//
//  STMCampaignPicturePVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignPicturePVC.h"
#import "STMCampaignPicture.h"
#import "STMCampaignPictureVC.h"

@interface STMCampaignPicturePVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSUInteger nextIndex;
@property (nonatomic, strong) NSArray *picturesArray;

@end

@implementation STMCampaignPicturePVC

- (NSArray *)picturesArray {
    
    if (!_picturesArray) {
        
        _picturesArray = [self.campaign.pictures sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(compare:)]]];
        
    }
    
    return _picturesArray;
    
}

- (void)createVCs {
    
    NSMutableArray *vcs = [NSMutableArray array];
    
    for (int i = 0; i < self.picturesArray.count; i++) {
        
        STMCampaignPictureVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"campaignPictureVC"];
        
        vc.picture = self.picturesArray[i];
        vc.index = i;

        [vcs insertObject:vc atIndex:i];
        
    }

}

- (STMCampaignPictureVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    if ((self.campaign.pictures.count == 0) || (index >= self.campaign.pictures.count)) {

        return nil;

    } else {
    
        STMCampaignPictureVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"campaignPictureVC"];

        vc.picture = self.picturesArray[index];
        vc.index = index;
        
        return vc;
        
    }

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
    
    STMCampaignPictureVC *pendingVC = pendingViewControllers[0];
    self.nextIndex = pendingVC.index;
    
//    NSLog(@"pendingVC %@", pendingVC);
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        
        self.currentIndex = self.nextIndex;
        self.title = [(STMCampaignPicture *)self.picturesArray[self.currentIndex] name];
        
//        NSLog(@"previousViewControllers %@", previousViewControllers);
        
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

//    [self createVCs];
    
    STMCampaignPictureVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];

    
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
