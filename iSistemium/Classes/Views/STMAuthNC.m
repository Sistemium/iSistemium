//
//  STMAuthNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAuthNC.h"
#import "STMAuthController.h"

@interface STMAuthNC ()

@end

@implementation STMAuthNC


- (void)authControllerStateChanged {
    
}


#pragma mark - viewlifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(authControllerStateChanged)
               name:@"authControllerStateChanged"
             object:[STMAuthController authController]];
    
//    [nc addObserver:self
//           selector:@selector(syncerStatusChanged:)
//               name:@"syncStatusChanged"
//             object:[[STMSessionManager sharedManager].currentSession syncer]];
//    
//    [nc addObserver:self
//           selector:@selector(entityCountdownChange:)
//               name:@"entityCountdownChange"
//             object:[[STMSessionManager sharedManager].currentSession syncer]];
//    
//    [nc addObserver:self
//           selector:@selector(newAppVersionAvailable:)
//               name:@"newAppVersionAvailable"
//             object:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
