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

@interface STMCampaignDetailsPVC ()

@property (nonatomic, strong) UIBarButtonItem *homeButton;
@property (nonatomic, strong) STMDocument *document;


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
        
        _campaign = campaign;
        
//        self.campaignPicturesResultsController = nil;
//        self.photoReportPicturesResultsController = nil;
//        [self fetchPictures];
//        [self fetchPhotoReport];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
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
