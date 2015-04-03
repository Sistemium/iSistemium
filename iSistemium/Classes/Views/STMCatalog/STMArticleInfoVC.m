//
//  STMArticleInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleInfoVC.h"

@interface STMArticleInfoVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *articleInfo;


@end


@implementation STMArticleInfoVC

- (NSMutableArray *)articleInfo {
    
    if (!_articleInfo) {
        _articleInfo = [NSMutableArray array];
    }
    return _articleInfo;
    
}

- (void)closeButtonPressed {
    [self.parentVC dismissArticleInfoPopover];
}

- (void)setupImage {
    
    if (self.article.pictures.count > 0) {

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
        STMArticlePicture *picture = [self.article.pictures sortedArrayUsingDescriptors:@[sortDescriptor]][0];
        
        self.imageView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:picture.resizedImagePath]];
    
    } else {
        self.imageView.image = [UIImage imageNamed:@"wine_bottle-512.png"];
    }
    
}

- (void)setupToolbar {
    
    CGFloat height = 44;
    CGFloat width = self.view.frame.size.width;
    CGFloat x = self.view.frame.origin.x;
    CGFloat y = self.view.frame.size.height - height;
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    
    [toolbar setItems:@[flexibleSpace, closeButton]];

    [self.view addSubview:toolbar];
    
}

- (void)prepareInfo {

    [self.articleInfo addObject:@{
                                  @"key": @"name",
                                  @"value": (self.article.name) ? self.article.name : @""
                                  }];
    
    if (self.article.extraLabel)
        [self.articleInfo addObject:@{
                                      @"key": @"extraLabel",
                                      @"value": (self.article.extraLabel) ? self.article.extraLabel : @""
                                      }];

    
    NSString *keyString = NSLocalizedString(@"VOLUME", nil);
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    NSString *valueString = [NSString stringWithFormat:@"%@: %@%@", keyString, self.article.pieceVolume, volumeUnitString];
    [self.articleInfo addObject:@{
                                  @"key": @"pieceVolume",
                                  @"value": valueString
                                  }];

    keyString = NSLocalizedString(@"FACTOR", nil);
    valueString = [NSString stringWithFormat:@"%@: %@", keyString, self.article.factor];
    [self.articleInfo addObject:@{
                                  @"key": @"factor",
                                  @"value": valueString
                                  }];
    
    keyString = NSLocalizedString(@"PACKAGE REL", nil);
    valueString = [NSString stringWithFormat:@"%@: %@", keyString, self.article.packageRel];
    [self.articleInfo addObject:@{
                                  @"key": @"packageRel",
                                  @"value": valueString
                                  }];

    NSSortDescriptor *priceDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priceType.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *prices = [self.article.prices sortedArrayUsingDescriptors:@[priceDescriptor]];
    
    for (STMPrice *price in prices) {
        
        keyString = NSLocalizedString(@"PRICE", nil);
        NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
        NSString *priceValue = [numberFormatter stringFromNumber:price.price];
        valueString = [NSString stringWithFormat:@"%@: %@", keyString, priceValue];
        [self.articleInfo addObject:@{
                                      @"key": price.priceType.name,
                                      @"value": valueString,
                                      @"detail": price.priceType.name
                                      }];
        
    }
    
    keyString = NSLocalizedString(@"STOCK", nil);
    NSString *stockVolume = ([self.article.stock.volume integerValue] > 0) ? self.article.stock.displayVolume : NSLocalizedString(@"ZERO STOCK", nil);
    valueString = [NSString stringWithFormat:@"%@: %@", keyString, stockVolume];
    [self.articleInfo addObject:@{
                                  @"key": @"stockVolume",
                                  @"value": valueString
                                  }];

/*
    keyString = NSLocalizedString(@"CODE", nil);
    valueString = [NSString stringWithFormat:@"%@: %@", keyString, self.article.code];
    [self.articleInfo addObject:@{
                                  @"key": @"code",
                                  @"value": valueString
                                  }];

    keyString = NSLocalizedString(@"SECTION", nil);
    valueString = [NSString stringWithFormat:@"%@: %@", keyString, self.article.articleGroup.name];
    [self.articleInfo addObject:@{
                                  @"key": @"section",
                                  @"value": valueString
                                  }];
*/

}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static CGFloat standardCellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
    });
    
    return standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        static STMInfoTableViewCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken,^{
            cell = [[STMInfoTableViewCell alloc] init];
        });

        [self fillCell:cell forIndexPath:indexPath];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];

        UIFont *font = [self boldFontForLabel:cell.textLabel];

        NSDictionary *attributes = @{NSFontAttributeName:font};
        
        CGSize lineSize = [cell.textLabel.text sizeWithAttributes:attributes];
        CGSize boundSize = CGSizeMake(cell.textLabel.frame.size.width, CGFLOAT_MAX);
        CGRect multilineRect = [cell.textLabel.text boundingRectWithSize:boundSize
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:attributes
                                                                 context:nil];
        
        CGFloat diff = ceil(multilineRect.size.height) - ceil(lineSize.height);
        
        CGFloat height = cell.frame.size.height + diff;
        
        return height;

    } else {
        return [self tableView:self.tableView estimatedHeightForRowAtIndexPath:indexPath];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articleInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"articleInfoCell";
    
    STMInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    [self setLabelsColor:[UIColor blackColor] forCell:cell];
    
    [self fillCell:cell forIndexPath:indexPath];
    
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    if ([self.article.stock.volume integerValue] <= 0) [self setLabelsColor:[UIColor lightGrayColor] forCell:cell];
    
    return cell;
    
}

- (void)fillCell:(STMInfoTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = self.articleInfo[indexPath.row];
    
    NSString *key = info[@"key"];
    
    cell.textLabel.text = info[@"value"];
    cell.detailTextLabel.text = info[@"detail"];
    
    if ([key isEqualToString:self.parentVC.selectedPriceType.name] || [key isEqualToString:@"name"]) {
        [self boldFontForCell:cell];
    }
    
    if ([key isEqualToString:@"name"]) {
        cell.textLabel.numberOfLines = 0;
    }
    
}

- (void)setLabelsColor:(UIColor *)color forCell:(STMInfoTableViewCell *)cell {

    cell.textLabel.textColor = color;
    cell.detailTextLabel.textColor = color;

}

- (void)boldFontForCell:(STMInfoTableViewCell *)cell {
    
    [self boldFontForLabel:cell.textLabel];
    [self boldFontForLabel:cell.detailTextLabel];
    
}

- (UIFont *)boldFontForLabel:(UILabel *)label {

    CGFloat fontSize = label.font.pointSize;
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    label.font = font;
    
    return font;

}

- (void)setupTableView {

    [self.tableView registerClass:[STMInfoTableViewCell class] forCellReuseIdentifier:@"articleInfoCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.separatorColor = [UIColor whiteColor];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    if (self.article) {
        
        [self setupImage];
        [self prepareInfo];
        [self setupTableView];
        
    }
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self setupToolbar];

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
