//
//  STMPickingOrderPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrderPositionsTVC.h"

#define SLIDE_THRESHOLD 20
#define ACTION_THRESHOLD 100


@interface STMPickingOrderPositionsTVC () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray <STMPickingOrderPosition *> *tableData;

@property (nonatomic) CGFloat slideStartPoint;
@property (nonatomic, strong) UITableViewCell *slidedCell;
@property (nonatomic) CGRect initialFrame;
@property (nonatomic) BOOL cellStartSliding;


@end


@implementation STMPickingOrderPositionsTVC

- (NSArray <STMPickingOrderPosition *> *)tableData {
    
    if (!_tableData) {
        
        if (self.pickingOrder) {
            
            NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord"
                                                                            ascending:YES
                                                                             selector:@selector(compare:)];
            
            _tableData = [self.pickingOrder.pickingOrderPositions sortedArrayUsingDescriptors:@[ordDescriptor]];
            
        } else {
            
            _tableData = @[];
            
        }

    }
    return _tableData;
    
}


#pragma mark - cell's height caching

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *object = self.tableData[indexPath.row];
    NSManagedObjectID *objectID = object.objectID;
    
    if (objectID) {
        self.cachedCellsHeights[objectID] = @(height);
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [self.tableData[indexPath.row] objectID];
    
    return self.cachedCellsHeights[objectID];
    
}


#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.pickingOrder.ndoc;
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom5TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom5TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom5TVCell class]]) {
        [self fillPickingOrderArticleCell:(STMCustom5TVCell *)cell atIndexPath:indexPath];
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillPickingOrderArticleCell:(STMCustom5TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrderPosition *pickingPosition = self.tableData[indexPath.row];
    
    cell.titleLabel.text = pickingPosition.article.name;
    cell.detailLabel.text = pickingPosition.ord.stringValue;
    cell.infoLabel.text = [STMFunctions volumeStringWithVolume:pickingPosition.volume.integerValue andPackageRel:pickingPosition.article.packageRel.integerValue];
    
}


#pragma mark - gestures

- (void)addPanGesture {
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    
    [self.tableView addGestureRecognizer:pan];
    
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            
            break;
            
        }
        case UIGestureRecognizerStateChanged: {
            
            CGFloat slideShift = [pan translationInView:pan.view].x;

            if (!self.cellStartSliding) {
                
                if (slideShift > SLIDE_THRESHOLD) {
                    
                    self.cellStartSliding = YES;
                    
                    self.tableView.scrollEnabled = NO;
                    
                    CGPoint startPoint = [pan locationInView:pan.view];
                    
                    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:startPoint];
                    self.slidedCell = [self.tableView cellForRowAtIndexPath:indexPath];
                    self.initialFrame = self.slidedCell.contentView.frame;
                    
                    self.slideStartPoint = startPoint.x;

                }
                
            } else {
                
                [self slideCellWithShift:slideShift];
                
            }
            
            break;
            
        }
        case UIGestureRecognizerStateEnded: {
            
            self.slidedCell.contentView.frame = self.initialFrame;
            self.cellStartSliding = NO;
            self.tableView.scrollEnabled = YES;
            break;
            
        }
        default: {
            break;
        }
    }
    
}

- (void)slideCellWithShift:(CGFloat)slideShift {
    
    if (self.initialFrame.origin.x + slideShift > 0) {
        
        self.slidedCell.contentView.frame = CGRectMake(self.initialFrame.origin.x + slideShift, self.initialFrame.origin.y, self.initialFrame.size.width, self.initialFrame.size.height);
    
    } else {
        
        self.slidedCell.contentView.frame = self.initialFrame;
        
    }
    
    if (slideShift > ACTION_THRESHOLD && self.slideStartPoint + slideShift > self.tableView.frame.size.width - SLIDE_THRESHOLD) {
        NSLog(@"cell's slide did moved enough distance and achive a right edge of the screen, it's a time to do something");
    }
    
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self addPanGesture];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom5TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
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
