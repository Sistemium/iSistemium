//
//  STMPhotoReportsFilterTVC_iphone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 02/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class STMPhotoReportsFilterTVC_iphone:STMPhotoReportsFilterTVC,UIPopoverPresentationControllerDelegate{
    
    fileprivate var currentGrouping:STMPhotoReportGrouping {
        let defaults = UserDefaults.standard
        let key = "currentGrouping_\(STMAuthController().userID)"
        if defaults.integer(forKey: key) == 1{
            return .campaign
        }else{
            return .outlet
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showSettings":
            segue.destination.popoverPresentationController?.delegate = self
        case "showPhotoReportByOutlet":
            (segue.destination as! STMPhotoReportsDetailTVC_iphone).selectedOutlet = sender as! STMOutlet
            (segue.destination as! STMPhotoReportsDetailTVC_iphone).selectedCampaignGroup = self.selectedCampaignGroup
            (segue.destination as! STMPhotoReportsDetailTVC_iphone).filterTVC = self
        case "showPhotoReportByCampaign":
            (segue.destination as! STMPhotoReportsDetailTVC_iphone).selectedCampaign = sender as! STMCampaign
            (segue.destination as! STMPhotoReportsDetailTVC_iphone).selectedCampaignGroup = self.selectedCampaignGroup
            (segue.destination as! STMPhotoReportsDetailTVC_iphone).filterTVC = self
        default:
            break
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (currentGrouping) {
        case .outlet:
            performSegue(withIdentifier: "showPhotoReportByOutlet", sender: self.resultsController.object(at: indexPath))
        case .campaign:
            performSegue(withIdentifier: "showPhotoReportByCampaign", sender: self.resultsController.object(at: indexPath))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.performFetch()
    }
    
}
