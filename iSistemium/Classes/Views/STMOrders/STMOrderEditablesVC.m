//
//  STMOrderEditablesVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrderEditablesVC.h"
#import "STMSaleOrderController.h"

#define H_SPACE 20
#define V_SPACE 10


@interface STMOrderEditablesVC ()

@end

@implementation STMOrderEditablesVC

- (void)setupHeader {
    
    UILabel *fromLabel = [[UILabel alloc] init];
    
    NSDictionary *attributes = @{NSFontAttributeName:fromLabel.font};

    NSString *text = [STMSaleOrderController labelForProcessing:self.fromProcessing];
    CGSize size = [text sizeWithAttributes:attributes];
    CGFloat width = ceil(size.width);
    CGFloat height = ceil(size.height);
    
    fromLabel.frame = CGRectMake(H_SPACE, V_SPACE, width, height);
    fromLabel.text = text;
    fromLabel.textColor = [STMSaleOrderController colorForProcessing:self.fromProcessing];
    
    [self.view addSubview:fromLabel];
    
    CGFloat h_edge = H_SPACE + width;
    CGFloat v_edge = V_SPACE + height;
    
    UILabel *midLabel = [[UILabel alloc] init];
    
    text = @">>>";
    size = [text sizeWithAttributes:attributes];
    width = ceil(size.width);
    height = ceil(size.height);

    midLabel.frame = CGRectMake(h_edge + H_SPACE, V_SPACE, width, height);
    midLabel.text = text;
    
    [self.view addSubview:midLabel];
    
    h_edge += H_SPACE + width;
    
    UILabel *toLabel = [[UILabel alloc] init];
    
    text = [STMSaleOrderController labelForProcessing:self.toProcessing];
    size = [text sizeWithAttributes:attributes];
    width = ceil(size.width);
    height = ceil(size.height);

    toLabel.frame = CGRectMake(h_edge + H_SPACE, V_SPACE, width, height);
    toLabel.text = text;
    toLabel.textColor = [STMSaleOrderController colorForProcessing:self.toProcessing];
    
    [self.view addSubview:toLabel];
    
    h_edge += H_SPACE + width;

    NSLog(@"h_edge %f, v_edge %f", h_edge, v_edge);
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self setupHeader];
    
    self.view.frame = CGRectMake(0, 0, 300, 150);

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {

    [self.view setNeedsDisplay];
    
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
