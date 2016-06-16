//
//  STMPhotoReportSettings_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMPhotoReportSettings_iphone:UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 320, height: 160)
        self.tableView.estimatedRowHeight = 45
        self.navigationItem.title = NSLocalizedString(self.navigationItem.title!, comment: "")
    }
    
    var groupingType:Int? = 0
    
    lazy var mainSettingsViewController:STMPhotoReportSettings_iphone = {
       return (self.navigationController?.viewControllers[0] as! STMPhotoReportSettings_iphone)
    }()
    
    @IBOutlet weak var onlyPhotosLabel: UILabel!{
        didSet{
            onlyPhotosLabel.text = NSLocalizedString(onlyPhotosLabel.text!, comment: "")
        }
    }
    
    @IBOutlet weak var groupingLabel: UILabel!{
        didSet{
            groupingLabel.text = NSLocalizedString(groupingLabel.text!, comment: "")
        }
    }
    
    @IBOutlet weak var onlyPhotosSwitcher: UISwitch!{
        didSet{
            let userID = STMAuthController().userID
            let key = "showDataOnlyWithPhotos_\(userID)"
            let defaults = NSUserDefaults.standardUserDefaults()
            let showDataOnlyWithPhotos = defaults.boolForKey(key)
            onlyPhotosSwitcher.on = showDataOnlyWithPhotos
        }
    }

    @IBOutlet weak var groupingTypeLabel: UILabel!{
        didSet{
            let defaults = NSUserDefaults.standardUserDefaults()
            let key = "currentGrouping_\(STMAuthController().userID)"
            groupingType = defaults.integerForKey(key)
            refreshGroupingTypeLabel()
        }
    }
    
    func refreshGroupingTypeLabel(){
        if groupingType == 0{
            self.groupingTypeLabel.text = NSLocalizedString("BY CAMPAIGNS", comment: "")
        }else{
            self.groupingTypeLabel.text = NSLocalizedString("BY OUTLETS", comment: "")
        }
    }
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneButton(sender: UIBarButtonItem) {
        if onlyPhotosSwitcher != nil{
            let userID = STMAuthController().userID
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setBool(onlyPhotosSwitcher.on, forKey: "showDataOnlyWithPhotos_\(userID)")
            defaults.setInteger(groupingType ?? 0, forKey: "currentGrouping_\(STMAuthController().userID)")
            defaults.synchronize()
            if let filter = self.navigationController?.popoverPresentationController?.delegate as? STMPhotoReportsFilterTVC_iphone{
                filter.performFetch()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            mainSettingsViewController.doneButton(sender)
        }
    }
    
    @IBOutlet weak var byCampaignCell: UITableViewCell!{
        didSet{
            byCampaignCell.textLabel!.text = NSLocalizedString(byCampaignCell.textLabel!.text!, comment: "")
            if mainSettingsViewController.groupingType == 0{
                byCampaignCell.accessoryType = .Checkmark
            }else{
                byCampaignCell.accessoryType = .None
            }
        }
    }
    
    @IBOutlet weak var byOutletCell: UITableViewCell!{
        didSet{
            byOutletCell.textLabel!.text = NSLocalizedString(byOutletCell.textLabel!.text!, comment: "")
            if mainSettingsViewController.groupingType == 1{
                byOutletCell.accessoryType = .Checkmark
            }else{
                byOutletCell.accessoryType = .None
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if byCampaignCell != nil && byOutletCell != nil{
            switch tableView.cellForRowAtIndexPath(indexPath)! {
            case byCampaignCell:
                byCampaignCell.accessoryType = .Checkmark
                byOutletCell.accessoryType = .None
                if let _ = groupingTypeLabel{
                    groupingType = 0
                }else{
                    mainSettingsViewController.groupingType = 0
                    mainSettingsViewController.refreshGroupingTypeLabel()
                }
            case byOutletCell:
                byCampaignCell.accessoryType = .None
                byOutletCell.accessoryType = .Checkmark
                if let _ = groupingTypeLabel{
                    groupingType = 1
                }else{
                    mainSettingsViewController.groupingType = 1
                    mainSettingsViewController.refreshGroupingTypeLabel()
                }
            default:
                break
            }
        }
    }
    
}