//
//  STMCampaignGroupTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 01/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMCampaignGroupTVC_iphone:STMCampaignGroupTVC, UIPopoverPresentationControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @IBOutlet weak var showAllButton: UIBarButtonItem!{
        didSet{
            showAllButton.title = NSLocalizedString(showAllButton.title!, comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFilterTVC", sender: (self.resultsController.object(at: indexPath)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showFilterTVC":
            (segue.destination as! STMPhotoReportsFilterTVC).title = (sender as! STMCampaignGroup).displayName()
            let campaignGroup = (sender as! STMCampaignGroup)
            (segue.destination as! STMPhotoReportsFilterTVC).selectedCampaignGroup = campaignGroup;
        case "showSettings":
            segue.destination.popoverPresentationController?.delegate = self
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        if let _ = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
}
