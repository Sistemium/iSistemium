//
//  STMPickedPositionsInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPickedPositionsInfoTVC.h"

#import "STMPickingOrdersProcessController.h"


@interface STMPickedPositionsInfoTVC () <UIGestureRecognizerDelegate, STMVolumePickerOwner>

@property (nonatomic, strong) UITextField *hiddenTextField;
@property (nonatomic, strong) STMVolumePicker *volumePicker;
@property (nonatomic, strong) STMBarButtonItemLabel *remainingLabel;


@end


@implementation STMPickedPositionsInfoTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPickingOrderPositionPicked class])];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"pickingOrderPosition == %@", self.position];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)setPosition:(STMPickingOrderPosition *)position {
    
    _position = position;
    
    [self performFetch];
    
}


#pragma mark - volume picker

- (void)setupVolumePicker {
    
    self.volumePicker = [[STMVolumePicker alloc] initWithFrame:CGRectMake(0, 0, 320, 162)];
    self.volumePicker.owner = self;
    self.volumePicker.packageRelIsLocked = YES;
    self.volumePicker.showPackageRel = NO;
    self.volumePicker.packageRel = self.position.article.packageRel.integerValue;
    
}

- (void)setupHiddenTextField {
    
    self.hiddenTextField = [[UITextField alloc] init];
    self.hiddenTextField.inputView = self.volumePicker;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT);
    
    STMBarButtonItemDone *doneButon = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                         target:self
                                                                                         action:@selector(toolbarDoneButtonPressed)];
    
    [toolbar setItems:@[[STMBarButtonItem flexibleSpace], doneButon] animated:YES];
    
    self.hiddenTextField.inputAccessoryView = toolbar;

    [self.view addSubview:self.hiddenTextField];

}

- (void)toolbarDoneButtonPressed {
    [self dismissKeyboard];
}

- (void)addTapGestureToDismissKeyboard {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.delegate = self;
    
    [self.view addGestureRecognizer:tap];

}

- (void)dismissKeyboard {
    
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (selectedIndexPath) [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    
    [self.hiddenTextField resignFirstResponder];
    
}

- (void)updateVolumePickerWithDataOfPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    NSNumber *volumeSum = [self.position.pickingOrderPositionsPicked valueForKeyPath:@"@sum.volume"];
    
    self.volumePicker.maxVolume = self.position.volume.integerValue - (volumeSum.integerValue - positionPicked.volume.integerValue);

    [self.volumePicker reloadAllComponents];

    self.volumePicker.selectedVolume = positionPicked.volume.integerValue;
    
}


#pragma mark - STMVolumePickerOwner

- (void)volumeSelected {

    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;

    if (selectedIndexPath) {
        
        STMPickingOrderPositionPicked *positionPicked = [self.resultsController objectAtIndexPath:selectedIndexPath];
        
        NSInteger newVolume = self.volumePicker.selectedVolume;
        
        [STMPickingOrdersProcessController updateVolumesWithNewVolume:newVolume forPositionPicked:positionPicked];

    }
    
}

- (void)packageRelSelected {
    
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if ([touch.view isDescendantOfView:cell]) return NO;
    }
    
    return YES;
    
}


#pragma mark - table data

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.position.article.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STMCustom5TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMPickingOrderPositionPicked *positionPicked = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = [self barCodeScanStringForPositionPicked:positionPicked];
    
    cell.detailLabel.text = nil;
    
    NSString *volumeString = [STMFunctions volumeStringWithVolume:positionPicked.volume.integerValue
                                                    andPackageRel:positionPicked.article.packageRel.integerValue];
    
    cell.infoLabel.text = volumeString;
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ([self.position.pickingOrder orderIsProcessed]) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        STMPickingOrderPositionPicked *positionPicked = [self.resultsController objectAtIndexPath:indexPath];
        [STMPickingOrdersProcessController updateVolumesWithDeletePositionPicked:positionPicked];
        
    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    
    if (selectedIndexPath && [indexPath compare:selectedIndexPath] == NSOrderedSame) {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self dismissKeyboard];
        
        return nil;
        
    } else {
        
        return indexPath;
        
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrderPositionPicked *positionPicked = [self.resultsController objectAtIndexPath:indexPath];
    
    [self updateVolumePickerWithDataOfPositionPicked:positionPicked];
    [self.hiddenTextField becomeFirstResponder];

}


#pragma mark - methods

- (NSString *)barCodeScanStringForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    NSDictionary *barCodeScanStats = [self barCodeScanStatsForPositionPicked:positionPicked];
    
    NSMutableArray *stringComponents = @[].mutableCopy;
    
    for (NSString *barCodeScan in barCodeScanStats.allKeys) {
        
        NSInteger barCodeScanCount = [barCodeScanStats[barCodeScan] integerValue];
        
        if (barCodeScanCount > 1) {
            [stringComponents addObject:[NSString stringWithFormat:@"%@(%@)", barCodeScan, barCodeScanStats[barCodeScan]]];
        } else {
            [stringComponents addObject:[NSString stringWithFormat:@"%@", barCodeScan]];
        }
        
    }
    
    return [stringComponents componentsJoinedByString:@", "];
    
}

- (NSDictionary *)barCodeScanStatsForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    NSMutableDictionary *barCodeScanStats = @{}.mutableCopy;

    NSArray *barCodeScans = [self barCodeScansForPositionPicked:positionPicked];
    
    NSArray *distinctBarCodeScans = [[self barCodeScansForPositionPicked:positionPicked] valueForKeyPath:@"@distinctUnionOfObjects.code"];
    
    for (NSString *barCodeScan in distinctBarCodeScans) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"code == %@", barCodeScan];
        
        barCodeScanStats[barCodeScan] = @([barCodeScans filteredArrayUsingPredicate:predicate].count);
        
    }
    
    return barCodeScanStats;
    
}

- (NSArray *)barCodeScansForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMBarCodeScan class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"destinationXid == %@", positionPicked.xid];
    
    NSArray *barCodeScans = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    return barCodeScans;
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
    
    [self updateRemainingLabel];
    
}


#pragma mark - toolbar

- (void)setupRemainingLabel {
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    self.remainingLabel = [[STMBarButtonItemLabel alloc] initWithTitle:@""
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    
    [self setToolbarItems:@[flexibleSpace, self.remainingLabel, flexibleSpace]];

    [self updateRemainingLabel];
    
}

- (void)updateRemainingLabel {

    NSNumber *volumeSum = [self.position.pickingOrderPositionsPicked valueForKeyPath:@"@sum.volume"];

    NSInteger remainingVolume = self.position.volume.integerValue - volumeSum.integerValue;
    
    NSString *remainingVolumeString = [STMFunctions volumeStringWithVolume:remainingVolume
                                                             andPackageRel:self.position.article.packageRel.integerValue];
    
    self.remainingLabel.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"REMAIN TO PICK", nil), remainingVolumeString];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self setupVolumePicker];
    [self setupHiddenTextField];
    [self addTapGestureToDismissKeyboard];
    [self setupRemainingLabel];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom5TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

    [self performFetch];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
