//
//  STMBasketPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBasketPositionsTVC.h"
#import "STMBasketNC.h"

#define NUMBER_OF_NON_POSITION_SECTIONS 0

@interface STMBasketPositionsTVC ()

@property (nonatomic, weak) STMOutlet *outlet;
@property (nonatomic, strong) UIFont *standardLabelFont;
@property (nonatomic, strong) STMBasketPosition *selectedBasketPosition;


@end


@implementation STMBasketPositionsTVC

@synthesize resultsController = _resultsController;

- (instancetype)initWithOutlet:(id)outlet {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        self.outlet = outlet;
        self.title = self.outlet.shortName;

    }
    return self;

}

- (STMBasketNC *)basketNC {
    
    if ([self.navigationController isKindOfClass:[STMBasketNC class]]) {
        
        return (STMBasketNC *)self.navigationController;
        
    } else {
        
        return nil;
        
    }
    
}

- (NSString *)cellIdentifier {
    return @"basketPositionCell";
}

- (UIFont *)standardLabelFont {
    
    if (!_standardLabelFont) {
        
        _standardLabelFont = [[STMLabel alloc] init].font;
        
    }
    return _standardLabelFont;
    
}

- (NSFetchedResultsController *)resultsController {

    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMBasketPosition class])];

        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                  ascending:YES
                                                                   selector:@selector(caseInsensitiveCompare:)]];
        
        request.predicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.outlet];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        
    }
    return _resultsController;
    
}


#pragma mark - tableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_NON_POSITION_SECTIONS + self.resultsController.fetchedObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.selectedBasketPosition) {
        
        NSUInteger selectedIndex = [self.resultsController.fetchedObjects indexOfObject:self.selectedBasketPosition];
        
        if (section == selectedIndex + NUMBER_OF_NON_POSITION_SECTIONS) {
            
            return 3;
            
        }

    }
    
    return 1;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section >= NUMBER_OF_NON_POSITION_SECTIONS) ? 5 : 20;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.standardCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.standardCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMBasketPosition *basketPosition = self.resultsController.fetchedObjects[indexPath.section];
    
    cell.textLabel.text = basketPosition.article.name;

    cell.accessoryView = [self infoLabelForBasketPosition:basketPosition];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedBasketPosition = self.resultsController.fetchedObjects[indexPath.section];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedBasketPosition) {
        
        NSUInteger selectedIndex = [self.resultsController.fetchedObjects indexOfObject:self.selectedBasketPosition];
        
        if (indexPath.section == selectedIndex + NUMBER_OF_NON_POSITION_SECTIONS) {
            
        }
        
    }

    self.selectedBasketPosition = nil;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];

}


#pragma mark - cell filling

- (STMLabel *)infoLabelForBasketPosition:(STMBasketPosition *)basketPosition {

    NSAttributedString *infoLabelText = [self attributedStringForBasketPosition:basketPosition];
    CGSize size = infoLabelText.size;
    CGRect labelFrame = CGRectMake(0, 0, size.width, size.height);
    
    STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:labelFrame];
    infoLabel.attributedText = infoLabelText;
    infoLabel.textAlignment = NSTextAlignmentRight;
    
    return infoLabel;
    
}

- (NSAttributedString *)attributedStringForBasketPosition:(STMBasketPosition *)basketPosition {
    
    NSMutableAttributedString *infoLabelText = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if (basketPosition.volumeOne.integerValue > 0) {
        
        [self attributedString:infoLabelText
                  appendString:basketPosition.volumeOne.stringValue
                     withColor:[UIColor greenColor]
                       andFont:self.standardLabelFont];

    }
    
    if (basketPosition.volumeTwo.integerValue > 0) {
        
        if (basketPosition.volumeOne.integerValue > 0) {

            [self attributedString:infoLabelText
                      appendString:@" + "
                         withColor:[UIColor blackColor]
                           andFont:self.standardLabelFont];

        }
        
        [self attributedString:infoLabelText
                  appendString:basketPosition.volumeTwo.stringValue
                     withColor:[UIColor redColor]
                       andFont:self.standardLabelFont];

    }

    return infoLabelText;
    
}

- (void)attributedString:(NSMutableAttributedString *)attributedString appendString:(NSString *)appendString withColor:(UIColor *)color andFont:(UIFont *)font {
    
    if (appendString) {
        
        NSDictionary *attributes = @{NSFontAttributeName: font,
                                     NSForegroundColorAttributeName: color};
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:appendString
                                                                     attributes:attributes];
        
        [attributedString appendAttributedString:string];

    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];

    [self performFetch];
        
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
