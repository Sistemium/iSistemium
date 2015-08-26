//
//  STMOrderEditablesVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrderEditablesVC.h"

#define H_SPACE 20
#define V_SPACE 20
#define TEXT_VIEW_WIDTH 350
#define TEXT_VIEW_HEIGHT 50
#define TOOLBAR_HEIGHT 44;

@interface STMOrderEditablesVC ()

@property (nonatomic) CGFloat h_edge;
@property (nonatomic) CGFloat v_edge;
@property (nonatomic) CGFloat textView_h_start;

@property (nonatomic, strong) NSMutableDictionary *fields;

@end


@implementation STMOrderEditablesVC

- (NSMutableDictionary *)fields {
    
    if (!_fields) {
        _fields = [NSMutableDictionary dictionary];
    }
    return _fields;
    
}

- (void)setupHeader {
    
    CGSize size;
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat h_edge = 0;
    CGFloat v_edge = 0;
    NSString *text;
    NSDictionary *attributes;
    
    UILabel *toLabel = [[UILabel alloc] init];
    attributes = @{NSFontAttributeName:toLabel.font};
    text = [STMSaleOrderController labelForProcessing:self.toProcessing];
    size = [text sizeWithAttributes:attributes];
    width = ceil(size.width);
    height = ceil(size.height);

    toLabel.frame = CGRectMake(h_edge + H_SPACE, V_SPACE, width, height);
    toLabel.text = text;
    toLabel.textColor = [STMSaleOrderController colorForProcessing:self.toProcessing];
    
    [self.view addSubview:toLabel];
    
    h_edge += H_SPACE + width;
    v_edge = MAX((V_SPACE + height), v_edge);

    self.h_edge = MAX(self.h_edge, h_edge);
    self.v_edge = MAX(self.v_edge, v_edge);
    
}

- (void)setupFields {
    
    if (self.editableFields.count > 0) {
        
        self.fields[@"fields"] = self.editableFields;
        
        NSArray *labels = @[];
        
        for (NSString *field in self.editableFields) {
            
            labels = [labels arrayByAddingObjectsFromArray:@[[STMSaleOrderController labelForEditableProperty:field]]];
            
        }
        
        self.fields[@"labels"] = labels;
        
        self.textView_h_start = [self maxWidthForLabels:labels] + H_SPACE;
        
        NSArray *textViews = @[];
        
        for (NSString *name in labels) {
            
            textViews = [textViews arrayByAddingObjectsFromArray:@[[self setupEditableFieldWithName:name]]];
            
        }
        
        self.fields[@"textViews"] = textViews;
        
        if (textViews.count > 0) {
            [textViews[0] becomeFirstResponder];
        }

    }
    
}

- (CGFloat)maxWidthForLabels:(NSArray *)labels {
    
    CGFloat width = 0;
    NSDictionary *attributes = @{NSFontAttributeName:[self labelFont]};
    
    for (NSString *name in labels) {
        
        CGSize size = [name sizeWithAttributes:attributes];
        width = MAX(ceil(size.width), width);

    }
    
    return width;
    
}

- (UIFont *)labelFont {

    UILabel *label = [[UILabel alloc] init];
    return label.font;

}

- (UITextView *)setupEditableFieldWithName:(NSString *)name {
    
    CGSize size;
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat h_edge = 0;
    CGFloat v_edge = 0;
    NSString *text;
    NSDictionary *attributes;
    
    // Setup label:
    
    UILabel *nameLabel = [[UILabel alloc] init];
    attributes = @{NSFontAttributeName:nameLabel.font};
    text = name;
    size = [text sizeWithAttributes:attributes];
    width = ceil(size.width);
    height = ceil(size.height);
    
    nameLabel.frame = CGRectMake(H_SPACE, self.v_edge + V_SPACE, width, height);
    nameLabel.text = text;
    nameLabel.textColor = [UIColor grayColor];
    
    [self.view addSubview:nameLabel];

    // Setup textview:
    
    UITextView *tv = [[UITextView alloc] init];
    width = TEXT_VIEW_WIDTH;
    height = TEXT_VIEW_HEIGHT;
    
    tv.frame = CGRectMake(self.textView_h_start + H_SPACE, self.v_edge + V_SPACE, width, height);
    tv.layer.borderColor = [[UIColor grayColor] CGColor];
    tv.layer.borderWidth = 1.0f;
    
    [self.view addSubview:tv];
    
    h_edge = self.textView_h_start + H_SPACE + width;
    v_edge = MAX((self.v_edge + V_SPACE + height), v_edge);
    
    
    self.h_edge = MAX(self.h_edge, h_edge);
    self.v_edge = MAX(self.v_edge, v_edge);
    
    return tv;

}

- (void)setupButtons {

    CGFloat height = TOOLBAR_HEIGHT;

    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, self.v_edge + V_SPACE, self.h_edge + H_SPACE, height);
    
    STMBarButtonItemCancel *cancelButton = [[STMBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                target:self
                                                                                                action:@selector(cancelButtonPressed)];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonPressed)];

    [toolbar setItems:@[cancelButton, flexibleSpace, doneButton]];
    
    [self.view addSubview:toolbar];
    
    self.v_edge += height + V_SPACE;
    
}


#pragma mark - buttons

- (void)cancelButtonPressed {

    [self.popover dismissPopoverAnimated:YES];
    [self.popover.delegate popoverControllerDidDismissPopover:self.popover];
    
}

- (void)doneButtonPressed {
    
    NSMutableDictionary *editableValues = [NSMutableDictionary dictionary];
    
    NSArray *textViews = self.fields[@"textViews"];
    
    for (UITextView *tv in textViews) {
        
        if (tv.text && ![[tv.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {

            NSUInteger index = [textViews indexOfObject:tv];
            NSString *editableField = self.fields[@"fields"][index];
            
            editableValues[editableField] = tv.text;
            
        }
        
    }
    
    [STMSaleOrderController setProcessing:self.toProcessing forSaleOrder:self.saleOrder withFields:editableValues];
    
    [self.popover dismissPopoverAnimated:YES];
    [self.popover.delegate popoverControllerDidDismissPopover:self.popover];

}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.h_edge = 0;
    self.v_edge = 0;
    
    [self setupHeader];
    [self setupFields];
    [self setupButtons];
    
    self.view.frame = CGRectMake(0, 0, self.h_edge + H_SPACE, self.v_edge);

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self.view setNeedsDisplay];
    
    [super viewWillAppear:animated];
    
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
