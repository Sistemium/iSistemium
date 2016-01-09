//
//  STMSupplyOrdersTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrdersTVC.h"

#import "STMSupplyOrdersSVC.h"


@interface STMSupplyOrdersTVC ()

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;

@property (nonatomic, strong) NSMutableDictionary *filterButtons;
@property (nonatomic, strong) NSMutableArray *currentFilterProcessings;


@end


@implementation STMSupplyOrdersTVC

@synthesize resultsController = _resultsController;

- (STMSupplyOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMSupplyOrdersSVC class]]) {
            _splitVC = (STMSupplyOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSupplyOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *ndocDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[dateDescriptor, ndocDescriptor];
        
        request.predicate = [self requestPredicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"dayAsString"
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (NSCompoundPredicate *)requestPredicate {

    NSMutableArray *subpredicates = @[].mutableCopy;
    
    for (NSString *processing in self.currentFilterProcessings) {
        
        NSPredicate *processingPredicate = [NSPredicate predicateWithFormat:@"processing != %@", processing];
        [subpredicates addObject:processingPredicate];
        
    }
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];

    return predicate;
    
}

- (void)performFetch {
    
    [super performFetch];
    
    if (![self.resultsController.fetchedObjects containsObject:self.splitVC.selectedSupplyOrder]) {
        
        self.splitVC.selectedSupplyOrder = nil;
        
    } else {
        
        NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedSupplyOrder];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }
    
    [self setupToolbar];
    
}

#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillSupplyOrderCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillSupplyOrderCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = supplyOrder.ndoc;
    
    NSUInteger positionsCount = supplyOrder.supplyOrderArticleDocs.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    
    NSString *positionsCountString = nil;
    
    if (positionsCount == 0) {
        positionsCountString = [NSString stringWithFormat:@"%@",NSLocalizedString(pluralTypeString, nil)];
    } else {
        positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    }

    cell.detailTextLabel.text = positionsCountString;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    [self addProcessingColorStripeForSupplyOrder:supplyOrder forCell:cell];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:indexPath];

    self.splitVC.selectedSupplyOrder = supplyOrder;

    if (IPHONE) {
        [self performSegueWithIdentifier:@"showArticleDocs" sender:indexPath];
    }
    
}

- (void)addProcessingColorStripeForSupplyOrder:(STMSupplyOrder *)supplyOrder forCell:(UITableViewCell *)cell {

    [[cell.contentView viewWithTag:1] removeFromSuperview];

    UIColor *processingColor = [STMWorkflowController colorForProcessing:supplyOrder.processing inWorkflow:self.splitVC.supplyOrderWorkflow];

    if (processingColor) {
        
        CGFloat fillWidth = 5;
        
        CGRect rect = CGRectMake(1, 1, fillWidth, cell.frame.size.height-2);
        UIView *view = [[UIView alloc] initWithFrame:rect];
        view.tag = 1;
        view.backgroundColor = (processingColor) ? processingColor : [UIColor clearColor];
        
        [cell.contentView addSubview:view];
        [cell.contentView sendSubviewToBack:view];

    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    [self setupToolbar];
    
}


#pragma mark - Navigation

- (void)segueToArticleDocs {
    
    if ([self.navigationController.topViewController isEqual:self]) {
        [self performSegueWithIdentifier:@"showArticleDocs" sender:nil];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showArticleDocs"] &&
        [segue.destinationViewController isKindOfClass:[STMSupplyOrderArticleDocsTVC class]]) {

        if ([sender isKindOfClass:[NSIndexPath class]]) {
            
            STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
            
            STMSupplyOrderArticleDocsTVC *articleDocsTVC = (STMSupplyOrderArticleDocsTVC *)segue.destinationViewController;
            articleDocsTVC.supplyOrder = supplyOrder;
            
        }
        
    }
    
}


#pragma mark - toolbar

- (void)setupToolbar {
    
    if ([self.navigationController.topViewController isEqual:self]) {

        NSString *propertyName = @"processing";
        
        NSArray *toolbarItems = [self toolbarItemsForPropertyName:propertyName];
        
        [self setScrollViewForToolbar:self.navigationController.toolbar withItems:toolbarItems];

    }
    
}

- (NSArray *)toolbarItemsForPropertyName:(NSString *)propertyName {
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    [toolbarItems addObject:flexibleSpace];
    
    NSArray *processings = [self processingLabelsForPropertyName:propertyName];
    
    for (NSDictionary *processing in processings) {
        
        NSString *processingName = processing[propertyName];
        
        STMBarButtonItem *button = self.filterButtons[processingName];
        
        if (!button) {
            
            button = [self filterButtonForProcessing:processingName];
            if (button) self.filterButtons[processingName] = button;
            
        }
        
        if (button) [toolbarItems addObject:button];
        
    }

    [toolbarItems addObject:flexibleSpace];
    
    return toolbarItems;
    
}

- (NSArray *)processingLabelsForPropertyName:(NSString *)propertyName {
    
    NSArray *processings = [self fetchSaleOrderProperty:propertyName];
    
    //    NSLog(@"processings %@", processings);
    
    NSMutableArray *processingLabels = [NSMutableArray array];
    
    for (NSDictionary *processing in processings) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:processing];
        dic[@"label"] = [STMWorkflowController labelForProcessing:processing[propertyName] inWorkflow:self.splitVC.supplyOrderWorkflow];
        
        [processingLabels addObject:dic];
        
    }
    
    NSSortDescriptor *labelDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES];
    
    NSArray *result = [processingLabels sortedArrayUsingDescriptors:@[labelDescriptor]];
    
    return result;
    
}

- (NSArray *)fetchSaleOrderProperty:(NSString *)property {
    
    NSString *entityName = NSStringFromClass([STMSupplyOrder class]);
    
    STMEntityDescription *entity = [STMEntityDescription entityForName:entityName inManagedObjectContext:self.document.managedObjectContext];
    
    NSPropertyDescription *entityProperty = entity.propertiesByName[property];
    
    if (entityProperty) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        request.resultType = NSDictionaryResultType;
        request.returnsDistinctResults = YES;
//        request.predicate = [self selectingPredicate];
        request.propertiesToFetch = @[property];
        
        NSArray *result = [self.document.managedObjectContext executeFetchRequest:request error:nil];
        
        return result;
        
    } else {
        
        return nil;
        
    }
    
}

- (void)setScrollViewForToolbar:(UIToolbar *)toolbar withItems:(NSArray *)toolbarItems {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height);
    scrollView.bounds = toolbar.bounds;
    scrollView.autoresizingMask = toolbar.autoresizingMask;
    scrollView.bounces = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    UIToolbar *filtersToolbar = [[UIToolbar alloc] init];
    filtersToolbar.autoresizingMask = UIViewAutoresizingNone;
    [filtersToolbar setItems:toolbarItems];
    
    CGRect frame = [self requiredFrameForToolbar:filtersToolbar];
    filtersToolbar.frame = frame;
    
    scrollView.contentSize = frame.size;
    
    scrollView.tag = 1;
    [[toolbar viewWithTag:1] removeFromSuperview];
    
    [scrollView addSubview:filtersToolbar];
    [toolbar addSubview:scrollView];
    
}

- (CGRect)requiredFrameForToolbar:(UIToolbar *)toolbar {
    
    BOOL firstSegmentedControl = YES;
    CGFloat minX = 0.0;
    CGFloat maxX = 0.0;
    
    for (UIView *view in toolbar.subviews) {
        
        if ([view isKindOfClass:[STMSegmentedControl class]]) {
            
            CGPoint origin = view.frame.origin;
            CGSize size = view.frame.size;
            
            if (firstSegmentedControl) {
                
                minX = origin.x;
                maxX = origin.x + size.width;
                firstSegmentedControl = NO;
                
            }
            
            minX = (minX <= origin.x) ? minX : origin.x;
            maxX = (maxX >= origin.x + size.width) ? maxX : origin.x + size.width;
            
        }
        
    }
    
    CGFloat padding = 10;
    CGFloat width = maxX - minX + 2 * padding;
    
    UIToolbar *standardToolbar = self.navigationController.toolbar;
    CGSize standardSize = standardToolbar.frame.size;
    
    CGFloat minWidth = standardSize.width;
    
    width = (width > minWidth) ? width : minWidth;
    
    return CGRectMake(0, 0, width, standardSize.height);
    
}

- (void)toolBarLayoutDone {
    [self setupToolbar];
}


#pragma mark - filter buttons

- (NSMutableDictionary *)filterButtons {
    
    if (!_filterButtons) {
        _filterButtons = [NSMutableDictionary dictionary];
    }
    return _filterButtons;
    
}

- (STMBarButtonItem *)filterButtonForProcessing:(NSString *)processing {
    
    NSString *filterProcessedLabel = [STMWorkflowController labelForProcessing:processing inWorkflow:self.splitVC.supplyOrderWorkflow];
    
    filterProcessedLabel = (filterProcessedLabel) ? filterProcessedLabel : processing;
    
    if (filterProcessedLabel) {
        
        STMSegmentedControl *filterProcessedSegmentedControl = [[STMSegmentedControl alloc] initWithItems:@[filterProcessedLabel]];
        filterProcessedSegmentedControl.selectedSegmentIndex = 0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterButtonPressed:)];
        [filterProcessedSegmentedControl addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(filterButtonLongPressed:)];
        [filterProcessedSegmentedControl addGestureRecognizer:longPress];
        
        STMBarButtonItem *filterButton = [[STMBarButtonItem alloc] initWithCustomView:filterProcessedSegmentedControl];
        return filterButton;
        
    } else {
        return nil;
    }
    
}

- (void)filterButtonPressed:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        STMSegmentedControl *segmentedControl = (STMSegmentedControl *)[(UITapGestureRecognizer *)sender view];
        NSString *processing = [self processingForSegmentedControl:segmentedControl];
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            
            segmentedControl.selectedSegmentIndex = -1;
            [self addFilterProcessing:processing];
            
        } else {
            
            segmentedControl.selectedSegmentIndex = 0;
            [self removeFilterProcessing:processing];
            
        }
        
    }
    
}

- (void)filterButtonLongPressed:(id)sender {
    
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
        
        UILongPressGestureRecognizer *longPressGesture = (UILongPressGestureRecognizer *)sender;
        
        if (longPressGesture.state == UIGestureRecognizerStateBegan) {
            
            self.currentFilterProcessings = nil;
            
            STMSegmentedControl *pressedControl = (STMSegmentedControl *)[(UITapGestureRecognizer *)sender view];
            NSString *pressedProcessing = [self processingForSegmentedControl:pressedControl];
            
            pressedControl.selectedSegmentIndex = 0;
            
            NSMutableArray *remainingProcessings = [self.filterButtons.allKeys mutableCopy];
            [remainingProcessings removeObject:pressedProcessing];
            
            BOOL isAlone = YES;
            
            for (NSString *key in remainingProcessings) isAlone &= ![self processingIsSelectedForButton:self.filterButtons[key]];
            
            [self setProcessings:remainingProcessings selected:isAlone];
            
        }
        
    }
    
}

- (NSString *)processingForSegmentedControl:(STMSegmentedControl *)segmentedControl {
    
    NSString *title = [segmentedControl titleForSegmentAtIndex:0];
    NSString *processing = [STMWorkflowController processingForLabel:title inWorkflow:self.splitVC.supplyOrderWorkflow];
    
    return processing;
    
}

- (NSMutableArray *)currentFilterProcessings {
    
    if (!_currentFilterProcessings) {
        _currentFilterProcessings = [NSMutableArray array];
    }
    return _currentFilterProcessings;
}

- (void)addFilterProcessing:(NSString *)processing {
    
    [self.currentFilterProcessings addObject:processing];
    [self performFetch];
    
}

- (void)removeFilterProcessing:(NSString *)processing {
    
    [self.currentFilterProcessings removeObject:processing];
    [self performFetch];
    
}

- (BOOL)processingIsSelectedForButton:(STMBarButtonItem *)button {
    
    STMSegmentedControl *control = [self segmentedControlForButton:button];
    return (control.selectedSegmentIndex != -1);
    
}

- (STMSegmentedControl *)segmentedControlForButton:(STMBarButtonItem *)button {
    
    if ([button.customView isKindOfClass:[STMSegmentedControl class]]) {
        return (STMSegmentedControl *)button.customView;
    } else {
        return nil;
    }
    
}

- (void)setProcessings:(NSArray *)processings selected:(BOOL)selected {
    
    for (NSString *processing in processings) {
        
        STMSegmentedControl *control = [self segmentedControlForButton:self.filterButtons[processing]];
        
        if (selected) {
            
            control.selectedSegmentIndex = 0;
            [self removeFilterProcessing:processing];
            
        } else {
            
            control.selectedSegmentIndex = -1;
            [self addFilterProcessing:processing];
            
        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"SUPPLY ORDERS", nil);
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(toolBarLayoutDone)
                                                 name:@"toolBarLayoutDone"
                                               object:self.navigationController.toolbar];

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
