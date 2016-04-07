//
//  STMUncashingInfoVC_iPhone.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 15/03/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import UIKit

class STMUncashingInfoVC_iPhone: STMUncashingInfoVC {
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var sumTextLabel: UILabel!
    @IBOutlet weak var typeTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBAction func cancelButtonPressed(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(){
        STMUncashingProcessController.sharedInstance().uncashingDone()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mainTextLabel.constraintWithIdentifier("minHeight")?.constant = mainTextLabel.requiredHeight(self.view.frame.width )
        sumTextLabel.constraintWithIdentifier("minHeight")?.constant = mainTextLabel.requiredHeight(self.view.frame.width )
        typeTextLabel.constraintWithIdentifier("minHeight")?.constant = mainTextLabel.requiredHeight(self.view.frame.width )
        if imageView.image != nil {
            mainTextLabel?.preferredMaxLayoutWidth = self.view.frame.width / 2
            sumTextLabel?.preferredMaxLayoutWidth = self.view.frame.width / 2
            typeTextLabel?.preferredMaxLayoutWidth = self.view.frame.width / 2
            mainTextLabel.constraintWithIdentifier("minHeight")?.constant = mainTextLabel.requiredHeight(self.view.frame.width / 2)
            sumTextLabel.constraintWithIdentifier("minHeight")?.constant = mainTextLabel.requiredHeight(self.view.frame.width / 2)
            typeTextLabel.constraintWithIdentifier("minHeight")?.constant = mainTextLabel.requiredHeight(self.view.frame.width / 2)
        }
        commentTextView.sizeToFit()
        self.preferredContentSize = CGSizeMake(500,150 + commentTextView.frame.size.height / 2)
    }
    
}

private extension UILabel{
    func requiredHeight(width:CGFloat) -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}

private extension UIView{
    func constraintWithIdentifier(identifier:String) -> NSLayoutConstraint?{
        if let constraint = (constraints.filter{$0.identifier == identifier}.first) {
            return constraint
        }
        return nil
    }
}