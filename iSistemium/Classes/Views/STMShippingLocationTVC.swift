//
//  STMShippingLocation.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 07/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import Foundation

class STMShippingLocationTVC:STMVariableCellsHeightTVC,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let LIMIT_COUNT = 4
    
    let IMAGE_PADDING : CGFloat = 6
    
    let CELL_IMAGES_SIZE:CGFloat = 54.0
    
    private var picturesView = UIView()
    
    var THUMB_SIZE:CGSize {
        return CGSizeMake(CELL_IMAGES_SIZE, CELL_IMAGES_SIZE)
    }

    var shippingLocation: STMShippingLocation?{
        didSet{
            tableView.reloadData()
        }
    }
    
    private var spinner = STMSpinnerView()
    
    var cameraOverlayView = UIView()
    
    private var selectedSourceType : UIImagePickerControllerSourceType?
    
    // Mark: resultsController
    
    private var _resultsController:NSFetchedResultsController?
    
    override var resultsController : NSFetchedResultsController? {
        get {
            if (_resultsController == nil) {
                let shippingFetchRequest = NSFetchRequest(entityName: "STMShipmentRoutePoint")
                shippingFetchRequest.sortDescriptors = [NSSortDescriptor(key: "deviceTs",ascending:false)]
                shippingFetchRequest.predicate = NSPredicate(format: "shippingLocation.name == %@", shippingLocation!.name)
                _resultsController = NSFetchedResultsController(fetchRequest: shippingFetchRequest, managedObjectContext: self.document.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                _resultsController!.delegate = self
            }
            
            return _resultsController
        }
        set {
            _resultsController = newValue
        }
    }
    
    //MARK: table view data
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        case 1:
            return (shippingLocation?.isLocationConfirmed ?? 0).boolValue ? 1 : 2
        case 2:
            return resultsController?.fetchedObjects?.count ?? 0
        default :
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return NSLocalizedString("SHIPPING LOCATION", comment: "")
        case 2:
            return NSLocalizedString("SHIPMENT ROUTE POINTS", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath:indexPath) as! STMCustom7TVCell
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                cell.titleLabel?.text = shippingLocation?.name
                cell.detailLabel?.text = ""
            case 1:
                cell.titleLabel?.text = shippingLocation?.address
                cell.detailLabel?.text = ""
            default:
                break
            }
        case 1:
            switch indexPath.row{
            case 0:
                    cell.titleLabel!.font = UIFont.boldSystemFontOfSize(cell.textLabel!.font.pointSize)
                    cell.titleLabel!.text = ""
                    cell.titleLabel!.textColor = UIColor.blackColor()
                    cell.titleLabel!.textAlignment = .Center
                    
                    cell.detailLabel!.text = "";
                    cell.detailLabel!.textColor = UIColor.blackColor()
                    cell.detailLabel!.textAlignment = .Center
                    
                    cell.viewWithTag(666)?.removeFromSuperview()
                    
                    if ((shippingLocation?.location) != nil) {
                        
                        cell.titleLabel!.text = NSLocalizedString("SHOW MAP", comment: "");
                        
                        if (!(shippingLocation?.isLocationConfirmed ?? 0).boolValue ) {
                            
                            cell.detailLabel!.text = NSLocalizedString("LOCATION NEEDS CONFIRMATION", comment: "");
                            cell.detailLabel!.textColor = UIColor.redColor()
                            
                        }
                    }
                
                    cell.accessoryType = .None
                
            case 1:
                cell.titleLabel!.text = ""
                cell.detailLabel!.text = ""
                self.picturesView.removeFromSuperview()
                
                self.picturesView = UIView()
                
                if (shippingLocation!.shippingLocationPictures.count == 0) {
                    
                    let blankPicture = self.blankPicture
                    
                    blankPicture.frame = CGRectMake(0, 0, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
                    
                    picturesView.addSubview(blankPicture)
                    
                } else {
                    
                    let showCount = (shippingLocation!.shippingLocationPictures.count > LIMIT_COUNT) ? LIMIT_COUNT : shippingLocation!.shippingLocationPictures.count;
                    
                    let sortDesriptor = NSSortDescriptor(key: "deviceTs", ascending: false, selector: "compare:")
                    let range = NSMakeRange(0, showCount)
                    
                    let photoArray = (shippingLocation!.shippingLocationPictures as NSSet).sortedArrayUsingDescriptors([sortDesriptor] )[range.toRange()!]
                    
                    for picture in photoArray {
                        
                        let pictureButton = self.pictureButtonWithPicture(picture as! STMPicture)
                        
                        let count = CGFloat(self.picturesView.subviews.count);
                        let x = (count > 0) ? count * (CELL_IMAGES_SIZE + IMAGE_PADDING) : 0;
                        
                        pictureButton.frame = CGRectMake(x, 0, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
                        
                        self.picturesView.addSubview(pictureButton)
                        
                    }
                    
                }
                
                
                let addButton = self.addPhotoButton
                
                var x = CGFloat(self.picturesView.subviews.count) * (CELL_IMAGES_SIZE + IMAGE_PADDING);
                
                addButton.frame = CGRectMake(x, 0, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
                
                self.picturesView.addSubview(addButton)
                
                let picturesWidth = CELL_IMAGES_SIZE * CGFloat(self.picturesView.subviews.count) + IMAGE_PADDING * CGFloat(self.picturesView.subviews.count - 1)
                x = ceil((cell.contentView.frame.size.width - picturesWidth) / 2);
                let y = ceil((cell.contentView.frame.size.height - CELL_IMAGES_SIZE) / 2);
                
                self.picturesView.frame = CGRectMake(x, y, picturesWidth, CELL_IMAGES_SIZE);
                
                cell.contentView.addSubview(self.picturesView)
                
                cell.accessoryType = .None
            default:
                break
            }
        case 2:
            cell.titleLabel?.text = (resultsController!.fetchedObjects![indexPath.row] as! STMShipmentRoutePoint).shipmentRoute.date?.description
            cell.detailLabel?.text = (resultsController!.fetchedObjects![indexPath.row] as! STMShipmentRoutePoint).shortInfo()
        default:
            break
        }
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section){
            
        case 1:
            switch (indexPath.row) {
            case 1:
                return CELL_IMAGES_SIZE + IMAGE_PADDING * 2;
            default:
                break;
            }
            
        default:
            break;
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            
            switch (indexPath.row) {
            case 0:
                performSegueWithIdentifier("showShippingLocationMap", sender:self.shippingLocation)
                
            default:
                break;
            }
            
        }
    }
    
    // MARK: photos
    
    private var blankPicture:UIView {
    
    let image = STMFunctions.resizeImage(UIImage(named:"Picture-100"), toSize:THUMB_SIZE).imageWithRenderingMode(.AlwaysTemplate)
    let imageView = UIImageView(image: image)
    imageView.tintColor = UIColor.lightGrayColor()
    
    return imageView;
    
    }
    
    private func pictureButtonWithPicture(picture : STMPicture) -> UIView{
    
    let imageView = UIImageView(image: UIImage(data: picture.imageThumbnail))
    
    let tap = UITapGestureRecognizer(target: self, action: "photoButtonPressed:")
    imageView.gestureRecognizers = [tap]
    imageView.userInteractionEnabled = true
    
    return imageView;
    
    }
    
    private var addPhotoButton : UIView {
    
    let imageView = UIImageView(image: STMFunctions.resizeImage(UIImage(named: "plus"), toSize:THUMB_SIZE))
    
    let tap = UITapGestureRecognizer(target: self, action: "addPhotoButtonPressed:")
    imageView.gestureRecognizers = [tap]
    imageView.userInteractionEnabled = true
    
    return imageView;
    
    }
    
    func addPhotoButtonPressed(sender:AnyObject) {
    self.showImagePickerForSourceType(.Camera)
    
    }
    
    func photoButtonPressed(sender:AnyObject) {
    
    if sender.isKindOfClass(UITapGestureRecognizer){
        let tappedView = (sender as! UIGestureRecognizer).view
        performSegueWithIdentifier("showPhotos",sender:tappedView)
    }
    
    }
    
    func showImagePickerForSourceType( imageSourceType:UIImagePickerControllerSourceType ){
    if UIImagePickerController.isSourceTypeAvailable(imageSourceType) {
        self.selectedSourceType = imageSourceType;
        self.presentViewController(self.imagePickerController!, animated: true, completion: nil)
        }
    
    }
    
    private var _imagePickerController:STMImagePickerController?
    
    var imagePickerController:STMImagePickerController? {
        get{
            if _imagePickerController == nil{
                _imagePickerController = STMImagePickerController()
                _imagePickerController!.delegate = self;
                
                _imagePickerController!.sourceType = self.selectedSourceType!;
                
                if _imagePickerController!.sourceType == .Camera {
                    
                    
                    _imagePickerController!.showsCameraControls = false
                    NSBundle.mainBundle().loadNibNamed("STMCameraOverlayView", owner: self, options: nil)
                    self.cameraOverlayView.backgroundColor = UIColor.clearColor()
                    self.cameraOverlayView.autoresizesSubviews = true
                    self.cameraOverlayView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight]
                    
                    //        if (SYSTEM_VERSION >= 8.0) {
                    let rootView = UIApplication.sharedApplication().keyWindow!.rootViewController!.view;
                    let originalFrame = UIScreen.mainScreen().bounds
                    let screenFrame = rootView.convertRect(originalFrame, fromView:nil)
                    self.cameraOverlayView.frame = screenFrame;
                    //        }
                    _imagePickerController!.cameraOverlayView = self.cameraOverlayView;
                }
            }
            
            return _imagePickerController
    
        }
        set{
            _imagePickerController = nil
        }
    }
    
    
    func saveImage(image:UIImage) {
    
        let shippingLocationPicture = STMObjectsController.newObjectForEntityName(NSStringFromClass(STMShippingLocationPicture), isFantom:false) as! STMShippingLocationPicture
        
        let jpgQuality = STMPicturesController.jpgQuality()
        
        STMPicturesController.setImagesFromData(UIImageJPEGRepresentation(image, jpgQuality),forPicture: shippingLocationPicture ,andUpload:true)
    
    shippingLocationPicture.shippingLocation = self.shippingLocation
        self.document.saveDocument{
            if ($0) {
                self.spinner.removeFromSuperview()
                self.tableView.reloadData()
            }
        }
    
    }
    
    func photoWasDeleted(photo:STMShippingLocationPicture) {
        tableView.reloadData()
    }
    
    // MARK: Camera buttons
    
    
    @IBAction func cameraButtonPressed(sender:AnyObject) {
    self.spinner = STMSpinnerView(frame: self.view.bounds)
    self.view.addSubview(self.spinner)
    self.imagePickerController!.cameraOverlayView!.addSubview(STMSpinnerView(frame: self.imagePickerController!.cameraOverlayView!.bounds))
    self.imagePickerController!.takePicture()
    }
    
    @IBAction func cancelButtonPressed(sender:AnyObject) {
    self.imagePickerControllerDidCancel(self.imagePickerController!)
    }
    
    @IBAction func photoLibraryButtonPressed(sender:AnyObject) {
    self.cancelButtonPressed(sender)
    self.showImagePickerForSourceType(.PhotoLibrary)
    }
    
    // MARK:  Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPhotos" {
            let picturesPVC = segue.destinationViewController as! STMShippingLocationPicturesPVC
            
            let sortDesriptor = NSSortDescriptor(key: "deviceTs", ascending: false, selector: "compare:")
            let photoArray = (shippingLocation!.shippingLocationPictures as NSSet).sortedArrayUsingDescriptors([sortDesriptor])
            
            picturesPVC.photoArray =  NSMutableArray(array: photoArray)
            let index = picturesView.subviews.indexOf(sender as! UIView)
            picturesPVC.currentIndex = UInt(index ?? 0)
            picturesPVC.parentVC = self as STMVariableCellsHeightTVC as? STMShipmentRoutePointTVC
        }
        if segue.identifier == "showShippingLocationMap" {
            
            let mapVC = segue.destinationViewController as! STMShippingLocationMapVC
            
            mapVC.point = resultsController?.fetchedObjects![0] as! STMShipmentRoutePoint
            
        }
    }

    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(false){
            self.saveImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
            self.imagePickerController = nil
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(false,completion: nil)
            imagePickerController = nil
    }
    
    // MARK: view lifecycle
    
    override func customInit() {
        super.customInit()
        self.cellIdentifier = "shippingLocationCell"
        let cellNib = UINib(nibName: NSStringFromClass(STMCustom7TVCell.self), bundle:nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier:self.cellIdentifier)
        performFetch()
    }
    
}