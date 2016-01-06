//
//  STMShippingLocationsTVC.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 04/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMShippingLocationsTVC: STMSearchableTVC{
    
    private var _resultsController:NSFetchedResultsController?
    
    override var resultsController : NSFetchedResultsController? {
        get {
            if (_resultsController == nil) {
                NSLog("STMShippingLocationsTVC.resultsController")
                let shippingFetchRequest = NSFetchRequest(entityName: "STMShippingLocation")
                shippingFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name",ascending:true, selector: "caseInsensitiveCompare:")]
                //shippingFetchRequest.predicate = self.predicate
                _resultsController = NSFetchedResultsController(fetchRequest: shippingFetchRequest, managedObjectContext: self.document.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                _resultsController!.delegate = self
            }
            
            return _resultsController
        }
        set {
            _resultsController = newValue
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func customInit() {
        super.customInit()
        cellIdentifier = "ShippingLocation"
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        self.tableView.registerClass(STMCustom9TVCell.self, forCellReuseIdentifier:self.cellIdentifier)
        //self.navigationItem.title = NSLocalizedString(@"ARTICLES", nil);
        self.performFetch()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController!.fetchedObjects!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath:indexPath) as! STMCustom9TVCell
        let location = self.resultsController!.objectAtIndexPath(indexPath) as! STMShippingLocation
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.text = location.deviceCts?.description
        return cell;
    }
    
}