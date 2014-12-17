//
//  STMAddOutletVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddOutletVC.h"

@interface STMAddOutletVC ()

@property (weak, nonatomic) IBOutlet UILabel *partnerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;



@end

@implementation STMAddOutletVC

- (NSString *)partnerName {
    
    if (!_partnerName) {
        
        _partnerName = (self.partner) ? self.partner.name : nil;
        
    }
    
    NSLog(@"_partnerName %@", _partnerName);
    
    return _partnerName;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"ADD OUTLET", nil);
    self.partnerNameLabel.text = self.partnerName;
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


@end
